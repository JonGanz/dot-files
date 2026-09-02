---
name: local-review
description: Local, GitHub/Bitbucket-free PR-style code review of a repo's branch changes against its merge-base with the repo's own default/root branch (never hardcoded to "develop"). Targets the current directory if it's a git repo, otherwise every git repo found in the current directory's direct subdirectories. When multiple repos are in scope, treats them as one feature/fix spanning repos and adds a dedicated cross-repo contract-compatibility pass (Moleculer actions/events, socket/REST payloads, shared schemas, DB migrations another repo's models reference) so a breaking change on one side isn't missed just because each repo's own diff looks internally consistent. Also reviews each repo for coding errors, inconsistencies (incl. across duplicated code paths like legacy/v2 variants), violations of the repo's own documented conventions, formatting/lint issues, dead code (locales, CSS rules, unused exports), and edge cases. Invoke on /local-review, optionally with specific repo names and/or --base <branch>.
argument-hint: [repo-name...] [--base <branch>]
---

# /local-review

Perform the review entirely against the local repository/repositories - never fetch a PR, never
use `gh`/`hub`/a Bitbucket API, never post comments. All input is `git` history and the working
tree; all output is the findings you report at the end.

Optional `$ARGUMENTS`:
- One or more repo names -> scope to just those subdirectories instead of all of them.
- `--base <branch>` -> override auto-detection of the root/default branch for every repo in
  scope (still resolved per-repo to that repo's own `origin/<branch>` where possible).

## Step 1 - Resolve scope

1. If the current directory itself is a git repo (`git rev-parse --is-inside-work-tree`
   succeeds, run from `.`), the scope is that single repo.
2. Otherwise, list direct subdirectories only (no recursion) and keep the ones where
   `git -C <dir> rev-parse --is-inside-work-tree` succeeds. That's your repo set. If `$ARGUMENTS`
   named specific repos, filter to those (error clearly if a named one isn't a git repo here).
3. If no repos are found either way, say so and stop.

## Step 2 - Per repo: find the merge-base (not a hardcoded branch)

For each repo, do **not** assume `develop`, `main`, or any fixed name. Resolve the actual root
branch:

1. If `--base <branch>` was given, use it for this repo too (verify it resolves - locally or as
   `origin/<branch>` - before relying on it).
2. Else prefer the remote's actual default branch: `git -C <repo> symbolic-ref refs/remotes/origin/HEAD`
   (strip `refs/remotes/origin/`). This is authoritative when set.
3. Else fall back to checking, in order, whether `develop`, `main`, `master` exist as
   `origin/<name>` (`git -C <repo> branch -a`) and use the first that does.
4. If the current branch's own upstream (`git -C <repo> rev-parse --abbrev-ref @{u}`) differs from
   the resolved root branch (e.g. it points at itself on origin), that's fine - the root branch
   from steps 2-3 is what you diff against, not the upstream.
5. If `origin/<root>` looks like it might be stale (very few or suspiciously many commits ahead),
   it's fine to `git -C <repo> fetch origin <root-branch>` once to refresh it - but never fetch
   unconditionally in a loop, and if a fetch hangs on credentials, abort it and note that the
   comparison is against a possibly-stale local ref rather than blocking the whole review on it.
6. Compute `merge_base=$(git -C <repo> merge-base HEAD origin/<root-branch>)` (fall back to the
   local `<root-branch>` if there's no remote-tracking ref). If this fails (unrelated histories,
   branch not found), report that clearly for this repo and skip its diff - don't guess a branch.
7. Diff scope is `$merge_base..HEAD` - i.e. **committed** changes on the current branch since it
   diverged from root, and **only** those. Never review unstaged or staged-but-uncommitted
   working-tree changes, even if the user's `$ARGUMENTS` doesn't say otherwise - if they want
   working-tree changes reviewed too, that's a different, explicit ask, not the default for this
   skill. Run `git -C <repo> status --short` and if it shows anything, name those files in your
   final text reply as "not reviewed (uncommitted)" so the user knows they were excluded - but
   never fold their content into the diff, the lint/test scope, or the findings.
8. If `HEAD` is even with `$merge_base` (nothing committed since divergence), report that and
   move on - there's nothing to review in this repo.

## Step 3 - Per repo: load the repo's own standards

Before judging anything a violation, read what this specific repo actually documents. Check for,
and read whichever exist:
- `CLAUDE.md`, `AGENTS.md`, `.claude/CLAUDE.md` (and any `@`-included files they reference)
- `STYLE.md`, `CONTRIBUTING.md`
- Lint/format config: `.eslintrc*`, `.prettierrc*`, `.editorconfig`, or language-equivalent
  (`.editorconfig`, `ruleset.xml`, `.stylecop.json`, etc. for non-JS stacks)
- A "Conventions"/"Testing"/"Style" section in `README.md` if no dedicated doc exists

Cite the actual rule (file + what it says) when you flag a violation - don't invent conventions
the repo doesn't document.

## Step 4 - Per repo: read the diff for real

1. `git -C <repo> log --oneline $merge_base..HEAD` - understand the shape of the change first.
2. `git -C <repo> diff $merge_base..HEAD` - read the whole thing, not just a truncated tail.
3. For any file where the diff changes logic (not pure formatting/locale/docs), open the full
   current file for surrounding context - a 3-line hunk out of context hides most real bugs.
4. Look specifically for **duplicated implementations of the same feature** (e.g. a legacy view
   next to a "v2"/rebrand variant, or the same logic copy-pasted across services) and check
   whether this change was applied to all of them consistently, or only one - a silent behavioral
   split between variants is a high-value finding.

## Step 5 - Actually run the tools, don't assume

For each repo, check `package.json` (or the language-appropriate manifest) for lint/test scripts
and run them **scoped to the changed files** - i.e. `git -C <repo> diff --name-only
$merge_base..HEAD`, not `git status`, so uncommitted files never enter the lint/test scope either
- where the tooling allows it:

```sh
npx eslint <changed files>          # or the repo's documented lint command
npx vitest run <changed spec files>  # or the repo's documented test command
```

- Cross-reference lint output against the diff: a warning on a line the diff didn't touch is
  pre-existing debt, not something this change introduced - don't misattribute it.
- If the repo documents a coverage bar for changed files (check the standards docs from Step 3),
  note whether changed/added source files have accompanying tests, and whether coverage was run.
- If a repo has no lint/test tooling wired up, say so plainly rather than skipping silently.

## Step 6 - Verify, don't guess, on anything about runtime behavior

If a finding rests on a claim about framework/runtime behavior you're not certain of (async
ordering, an i18n fallback chain, a reactivity/watch timing edge case, a library default) -
don't state it as fact from reading source alone. Write a small throwaway script or test that
exercises the real code path in the repo and confirms the actual behavior, then delete it before
finishing. Reading the source and reasoning about it is not verification when the runtime
behavior is what's actually in question - run it and see.

## Step 7 - Cross-repo contract compatibility (multi-repo scope only)

When more than one repo is in scope, that's the point of the review, not a coincidence: the user
is describing one feature/fix that spans repos, so the highest-value bugs live at the boundary
between them, not inside any single repo. A per-repo review done in isolation cannot catch these
- each repo can look perfectly internally consistent on its own, and the break only shows up when
you compare both sides of a contract. **Do not rely on the per-repo pass in Step 8 to catch this
- it structurally can't, since each per-repo agent never sees the other repos.**

Do a dedicated compatibility pass over **all** repos in scope together:

1. From each repo's diff (Step 4), pull out anything that is a contract surface between repos,
   e.g.:
   - Moleculer service `actions`/`events` definitions, and `broker.call`/`ctx.call`/`ctx.emit`/
     `ctx.broadcast` call sites (name, param schema, response shape, version)
   - Socket.io event/action names and payloads (`call(`, `callWithResponse(`, `.emit(`, `.on(`,
     `addListener(`)
   - REST routes and their client callers (route path/method definitions vs `axios`/`fetch` call
     sites)
   - Shared/duplicated DTOs, type/interface definitions, or JSON schemas describing a message
     payload
   - DB schema changes (migrations) that another repo's ORM models or raw queries reference
   - Any config/env key one repo now expects that another repo (or the deploy/Ansible config)
     is supposed to provide
2. For each contract-surface change, search the **other** repos in scope for anything that names
   or shapes that same contract - not just their diffs, their whole current tree. A repo that
   should have been updated for this feature but wasn't touched at all is itself a critical
   finding, not a clean bill of health. `grep -rn` the action/event/route/field name across each
   other repo to find its counterpart usage.
3. Check specifically for:
   - **Breaking rename/removal** - one side renamed or dropped a field/action/event the other
     side still sends or expects.
   - **Shape drift** - a required param added on one side without the other side supplying it (or
     a param one side now expects that the other still omits/expects differently).
   - **One-sided change** - a repo whose diff shows nothing touching this feature's contract even
     though it's a known consumer/producer of it. Flag this explicitly rather than silently
     treating "no diff there" as "nothing to check."
   - **Documented backward-compatibility rules being broken** - check each repo's own standards
     from Step 3 (e.g. "inter-app Moleculer actions/events must remain backward compatible with
     the prior version, never silently break existing consumers") against what the diff actually
     does.
4. This step needs simultaneous visibility into every repo's diff and full tree - never delegate
   it to one of the isolated per-repo agents in Step 8; it must be done by an agent (or by you
   directly) that was handed all the repos' paths and diffs together.

## Step 8 - Scale to repo count

- Single repo in scope: do Steps 2-6 directly yourself; skip Step 7 (nothing to cross-check).
- Multiple repos in scope: in **one message**, launch in parallel:
  - one `general-purpose` Agent per repo, doing Steps 3-6 on that repo alone, **and**
  - one additional `general-purpose` Agent dedicated entirely to Step 7, given every repo's path
    plus the diffs/merge-bases you already resolved in Steps 1-4, explicitly told to check
    cross-repo contract compatibility only - not to redo any single repo's internal review.
  Every subagent returns its findings as a structured list (file, summary, concrete failure
  scenario) rather than calling `ReportFindings` itself - you aggregate everything and report once
  at the end so findings across repos and the cross-repo pass all land in one place.

## Step 9 - Report

Call `ReportFindings` once, across all reviewed repos plus the cross-repo pass, most-severe first.
When more than one repo was reviewed, prefix each finding's `file` with `<repo-dir>/` so the repo
is unambiguous. For a cross-repo finding, set `file` to the path on the side you'd fix first (or
that has the diff), and name the counterpart repo/file explicitly in the summary and failure
scenario text so the boundary is clear without a second `file` field. Empty findings array if
nothing survived - don't pad with stylistic nitpicks to have something to show. For any repo that
had nothing to review (no diff, no tooling) or was skipped, say so briefly in your text reply, not
as a finding.
