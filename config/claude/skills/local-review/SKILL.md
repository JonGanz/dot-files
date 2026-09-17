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

## Step 2 - Per repo: run the prep script

Steps 2-5 of a prior version of this skill (merge-base resolution, diff extraction, standards-doc
discovery, scoped lint/test) are deterministic - no judgment calls needed - so they're a script,
not a sequence of ad-hoc `find`/`cat`/`grep` calls. Run it once per repo:

```sh
~/.claude/skills/local-review/prep.sh <repo-path> [--base <branch>] [--fetch]
```

- `<repo-path>` - absolute or relative path to the repo (from Step 1's scope).
- `--base <branch>` - pass through if `$ARGUMENTS` gave one; otherwise the script resolves the
  root branch itself (remote `HEAD`, then `develop`/`main`/`master` in that order - never a
  hardcoded guess).
- `--fetch` - only pass this if you have a specific reason to think `origin/<root>` is stale
  (e.g. it looks suspiciously far behind); it fetches once with a 20s timeout and falls back to
  the existing local ref silently on failure. Default: omit it.

The script prints the path to a generated Markdown report as its last line of output - read that
file. It contains, in order:
- resolved root branch + merge-base + HEAD
- uncommitted files (`git status --short`) - excluded from everything below; name these in your
  final reply as "not reviewed (uncommitted)"
- commit log and full diff for `$merge_base..HEAD` (**committed** changes only - never working-tree
  changes, even if `$ARGUMENTS` doesn't say otherwise)
- contents of whichever standards docs exist (`CLAUDE.md`, `AGENTS.md`, `.claude/CLAUDE.md`,
  `STYLE.md`, `CONTRIBUTING.md`) and which lint/format config files are present
- scoped lint/test output for changed files only (eslint/vitest/jest, whichever the repo has
  wired up in `node_modules/.bin`) - if a repo uses a different manifest/language or a lint/test
  runner the script doesn't recognize, it says so in the report; run that tooling yourself,
  scoped to the same changed-files list, rather than skipping it

If the script exits non-zero (no merge-base, unrelated histories, branch not found, nothing
committed since divergence), it explains why on stderr - report that clearly for this repo and
move on, don't guess a branch or fall back to manual git commands to route around it.

Cite the actual rule (file + what it says) when you flag a standards violation later - don't
invent conventions the repo doesn't document. Cross-reference lint output against the diff: a
warning on a line the diff didn't touch is pre-existing debt, not something this change
introduced.

## Step 3 - Per repo: read the diff for real

Using the report from Step 2:
1. Read the commit log first - understand the shape of the change.
2. Read the full diff, not just a truncated tail.
3. For any file where the diff changes logic (not pure formatting/locale/docs), open the full
   current file for surrounding context - a 3-line hunk out of context hides most real bugs.
4. Look specifically for **duplicated implementations of the same feature** (e.g. a legacy view
   next to a "v2"/rebrand variant, or the same logic copy-pasted across services) and check
   whether this change was applied to all of them consistently, or only one - a silent behavioral
   split between variants is a high-value finding.

## Step 4 - Verify, don't guess, on anything about runtime behavior

If a finding rests on a claim about framework/runtime behavior you're not certain of (async
ordering, an i18n fallback chain, a reactivity/watch timing edge case, a library default) -
don't state it as fact from reading source alone. Write a small throwaway script or test that
exercises the real code path in the repo and confirms the actual behavior, then delete it before
finishing. Reading the source and reasoning about it is not verification when the runtime
behavior is what's actually in question - run it and see.

## Step 5 - Cross-repo contract compatibility (multi-repo scope only)

When more than one repo is in scope, that's the point of the review, not a coincidence: the user
is describing one feature/fix that spans repos, so the highest-value bugs live at the boundary
between them, not inside any single repo. A per-repo review done in isolation cannot catch these
- each repo can look perfectly internally consistent on its own, and the break only shows up when
you compare both sides of a contract. **Do not rely on the per-repo pass in Step 6 to catch this
- it structurally can't, since each per-repo agent never sees the other repos.**

Do a dedicated compatibility pass over **all** repos in scope together:

1. From each repo's diff (Step 3), pull out anything that is a contract surface between repos,
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
     from Step 2 (e.g. "inter-app Moleculer actions/events must remain backward compatible with
     the prior version, never silently break existing consumers") against what the diff actually
     does.
4. This step needs simultaneous visibility into every repo's diff and full tree - never delegate
   it to one of the isolated per-repo agents in Step 6; it must be done by an agent (or by you
   directly) that was handed all the repos' paths and diffs together.

## Step 6 - Scale to repo count

- Single repo in scope: do Steps 2-4 directly yourself; skip Step 5 (nothing to cross-check).
- Multiple repos in scope: in **one message**, launch in parallel:
  - one `general-purpose` Agent per repo, doing Steps 2-4 on that repo alone, **and**
  - one additional `general-purpose` Agent dedicated entirely to Step 5, given every repo's path
    plus the prep reports you already generated in Step 2, explicitly told to check cross-repo
    contract compatibility only - not to redo any single repo's internal review.
  Every subagent returns its findings as a structured list (file, summary, concrete failure
  scenario) rather than calling `ReportFindings` itself - you aggregate everything and report once
  at the end so findings across repos and the cross-repo pass all land in one place.

## Step 7 - Report

Call `ReportFindings` once, across all reviewed repos plus the cross-repo pass, most-severe first.
When more than one repo was reviewed, prefix each finding's `file` with `<repo-dir>/` so the repo
is unambiguous. For a cross-repo finding, set `file` to the path on the side you'd fix first (or
that has the diff), and name the counterpart repo/file explicitly in the summary and failure
scenario text so the boundary is clear without a second `file` field. Empty findings array if
nothing survived - don't pad with stylistic nitpicks to have something to show. For any repo that
had nothing to review (no diff, no tooling) or was skipped, say so briefly in your text reply, not
as a finding.
