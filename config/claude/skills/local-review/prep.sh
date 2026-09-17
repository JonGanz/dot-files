#!/bin/bash
# Deterministic prep pass for the local-review skill. Collects everything Steps 2-5
# of SKILL.md need (merge-base, diff, standards docs, scoped lint/test) into one
# file per repo, so the agent does one Bash call + one Read instead of a dozen
# ad-hoc find/cat/grep round-trips.
#
# Usage: prep.sh <repo-path> [--base <branch>] [--fetch] [--out <dir>]
#
# Prints the path to the generated report file as the last line of stdout.

set -uo pipefail

REPO=""
BASE_OVERRIDE=""
DO_FETCH=0
OUT_DIR=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --base)
            BASE_OVERRIDE="$2"
            shift 2
            ;;
        --fetch)
            DO_FETCH=1
            shift
            ;;
        --out)
            OUT_DIR="$2"
            shift 2
            ;;
        *)
            if [[ -z "$REPO" ]]; then
                REPO="$1"
            else
                echo "Unexpected argument: $1" >&2
                exit 2
            fi
            shift
            ;;
    esac
done

if [[ -z "$REPO" ]]; then
    echo "Usage: prep.sh <repo-path> [--base <branch>] [--fetch] [--out <dir>]" >&2
    exit 2
fi

if [[ ! -d "$REPO" ]]; then
    echo "Not a directory: $REPO" >&2
    exit 1
fi

REPO="$(cd "$REPO" && pwd)"
REPO_NAME="$(basename "$REPO")"

if ! git -C "$REPO" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Not a git repo: $REPO" >&2
    exit 1
fi

if [[ -z "$OUT_DIR" ]]; then
    OUT_DIR="$(mktemp -d -t local-review.XXXXXX)"
fi
mkdir -p "$OUT_DIR"
REPORT="$OUT_DIR/${REPO_NAME}.md"

g() { git -C "$REPO" "$@"; }

# --- Step 2: resolve root branch + merge-base -------------------------------

root_branch=""
root_ref=""

if [[ -n "$BASE_OVERRIDE" ]]; then
    if g rev-parse --verify "origin/$BASE_OVERRIDE" >/dev/null 2>&1; then
        root_branch="$BASE_OVERRIDE"
        root_ref="origin/$BASE_OVERRIDE"
    elif g rev-parse --verify "$BASE_OVERRIDE" >/dev/null 2>&1; then
        root_branch="$BASE_OVERRIDE"
        root_ref="$BASE_OVERRIDE"
    else
        echo "--base $BASE_OVERRIDE does not resolve in $REPO_NAME" >&2
        exit 1
    fi
else
    symref="$(g symbolic-ref refs/remotes/origin/HEAD 2>/dev/null || true)"
    if [[ -n "$symref" ]]; then
        root_branch="${symref#refs/remotes/origin/}"
        root_ref="origin/$root_branch"
    else
        for candidate in develop main master; do
            if g rev-parse --verify "origin/$candidate" >/dev/null 2>&1; then
                root_branch="$candidate"
                root_ref="origin/$candidate"
                break
            fi
        done
    fi
fi

if [[ -z "$root_ref" ]]; then
    echo "Could not resolve a root branch in $REPO_NAME (no origin/HEAD, no develop/main/master)" >&2
    exit 1
fi

if [[ "$DO_FETCH" -eq 1 ]]; then
    timeout 20 git -C "$REPO" fetch origin "$root_branch" >/dev/null 2>&1 || \
        echo "note: fetch of origin/$root_branch timed out or failed, using existing local ref" >&2
fi

merge_base="$(g merge-base HEAD "$root_ref" 2>/dev/null || true)"
if [[ -z "$merge_base" ]]; then
    merge_base="$(g merge-base HEAD "$root_branch" 2>/dev/null || true)"
fi
if [[ -z "$merge_base" ]]; then
    echo "Could not compute merge-base against $root_ref in $REPO_NAME" >&2
    exit 1
fi

head_sha="$(g rev-parse HEAD)"

{
    echo "# local-review prep: $REPO_NAME"
    echo
    echo "- repo path: $REPO"
    echo "- root branch: $root_branch ($root_ref)"
    echo "- merge-base: $merge_base"
    echo "- HEAD: $head_sha"
    echo
} > "$REPORT"

if [[ "$merge_base" == "$head_sha" ]]; then
    echo "Nothing committed since divergence from $root_ref - HEAD is even with merge-base. Nothing to review in $REPO_NAME." >> "$REPORT"
    echo "$REPORT"
    exit 0
fi

# --- uncommitted files (named, never included in diff/lint/test scope) -----

uncommitted="$(g status --short)"
{
    echo "## Uncommitted (excluded from review - working tree only)"
    echo
    if [[ -n "$uncommitted" ]]; then
        echo '```'
        echo "$uncommitted"
        echo '```'
    else
        echo "(clean)"
    fi
    echo
} >> "$REPORT"

# --- Step 4: log + diff + changed files -------------------------------------

mapfile -t changed_files < <(g diff --name-only "$merge_base..HEAD")

{
    echo "## Commit log ($merge_base..HEAD)"
    echo
    echo '```'
    g log --oneline "$merge_base..HEAD"
    echo '```'
    echo
    echo "## Changed files"
    echo
    printf '%s\n' "${changed_files[@]}"
    echo
    echo "## Full diff ($merge_base..HEAD)"
    echo
    echo '```diff'
    g diff "$merge_base..HEAD"
    echo '```'
    echo
} >> "$REPORT"

# --- Step 3: repo's own documented standards --------------------------------

{
    echo "## Documented standards"
    echo
} >> "$REPORT"

for doc in CLAUDE.md AGENTS.md .claude/CLAUDE.md STYLE.md CONTRIBUTING.md; do
    if [[ -f "$REPO/$doc" ]]; then
        {
            echo "### $doc"
            echo
            echo '```'
            cat "$REPO/$doc"
            echo '```'
            echo
        } >> "$REPORT"
    fi
done

lint_configs=()
for pattern in .eslintrc .eslintrc.js .eslintrc.cjs .eslintrc.json .eslintrc.yml .prettierrc .prettierrc.js .prettierrc.json .editorconfig ruleset.xml .stylecop.json; do
    if [[ -f "$REPO/$pattern" ]]; then
        lint_configs+=("$pattern")
    fi
done

{
    echo "### Lint/format config present"
    echo
    if [[ "${#lint_configs[@]}" -gt 0 ]]; then
        printf -- '- %s\n' "${lint_configs[@]}"
    else
        echo "(none found at repo root)"
    fi
    echo
} >> "$REPORT"

# --- Step 5: scoped lint/test, changed files only ---------------------------

{
    echo "## Scoped lint/test (changed files only)"
    echo
} >> "$REPORT"

if [[ -f "$REPO/package.json" ]]; then
    lintable=()
    for f in "${changed_files[@]}"; do
        [[ -f "$REPO/$f" ]] || continue
        case "$f" in
            *.js|*.jsx|*.ts|*.tsx|*.vue) lintable+=("$f") ;;
        esac
    done

    if [[ "${#lintable[@]}" -gt 0 ]] && [[ -x "$REPO/node_modules/.bin/eslint" ]]; then
        {
            echo "### eslint (scoped)"
            echo
            echo '```'
            (cd "$REPO" && ./node_modules/.bin/eslint "${lintable[@]}" 2>&1)
            echo '```'
            echo
        } >> "$REPORT"
    elif [[ "${#lintable[@]}" -gt 0 ]]; then
        echo "note: lintable JS/TS/Vue files changed but no local eslint binary found at node_modules/.bin/eslint" >> "$REPORT"
        echo >> "$REPORT"
    fi

    test_files=()
    for f in "${changed_files[@]}"; do
        [[ -f "$REPO/$f" ]] || continue
        case "$f" in
            *.test.*|*.spec.*) test_files+=("$f") ;;
        esac
    done

    if [[ "${#test_files[@]}" -gt 0 ]]; then
        if [[ -x "$REPO/node_modules/.bin/vitest" ]]; then
            {
                echo "### vitest (scoped)"
                echo
                echo '```'
                (cd "$REPO" && ./node_modules/.bin/vitest run "${test_files[@]}" 2>&1)
                echo '```'
                echo
            } >> "$REPORT"
        elif [[ -x "$REPO/node_modules/.bin/jest" ]]; then
            {
                echo "### jest (scoped)"
                echo
                echo '```'
                (cd "$REPO" && ./node_modules/.bin/jest "${test_files[@]}" 2>&1)
                echo '```'
                echo
            } >> "$REPORT"
        else
            echo "note: test files changed but no local vitest/jest binary found in node_modules/.bin" >> "$REPORT"
            echo >> "$REPORT"
        fi
    else
        echo "note: no *.test.*/*.spec.* files among changed files" >> "$REPORT"
        echo >> "$REPORT"
    fi
else
    echo "note: no package.json at repo root - lint/test scoping skipped, do this manually if the repo uses a different manifest/language" >> "$REPORT"
    echo >> "$REPORT"
fi

echo "$REPORT"
