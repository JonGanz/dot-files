# Possible Improvements

Findings from a consistency and design review (2026-10-26). The overall
architecture (module contract, intent files, subshell isolation, config system)
is sound. Most issues are about result reporting and boilerplate that has been
copy-pasted across modules. Items are in priority order.

## 1. Report per-module results instead of always claiming success

**Done (2026-11-02):** `run_module` captures the subshell status, a summary is printed, exit is non-zero on failure, `--fail-fast` added.

**Problem:** `run_module` in `setup.sh` ignores the subshell's exit status.
There is no `set -e` or `set -o pipefail` anywhere. The final line is always
"Setup completed successfully!" even when a module failed. A failing download
scrolls past and is forgotten.

**Proposal:**
- Capture the subshell exit status in `run_module`.
- Track pass / fail / skipped per module in arrays.
- Print a summary table at the end of the run, for example:

  ```
  ==> Summary
  core/essentials     ok
  core/git            ok
  apps/wezterm        skipped (GUI, WSL)
  sdks/go             FAILED
  ```
- Exit non-zero if anything failed. Default to continuing past failures, with
  an optional `--fail-fast` flag to stop at the first one.

## 2. Add `install_github_release` to `lib/pkg.sh`

**Done (2026-11-02):** `install_github_release` and `download_file` in `lib/pkg.sh`, `get_arch` in `lib/env.sh` (item 5). Six modules collapsed; `core/fonts` uses `download_file` and a `.version` marker (10d).

**Problem:** `core/lazygit`, `apps/lazysql`, `apps/glow`, `core/lazydocker`,
`apps/zellij`, `core/oh-my-posh`, and `core/fonts` each re-implement the same
~40 lines: check installed version, map `uname -m` to an arch string,
`mktemp -d`, `curl`, `tar`, `sudo install`, cleanup. They differ in subtle
ways (some check the curl result, some do not).

**Proposal:** one helper, roughly:

```bash
# install_github_release <name> <version> <url_template> <path_in_archive> [version_cmd]
# url_template may use {version} and {arch}
install_github_release lazygit "$LAZYGIT_VERSION" \
    "https://github.com/jesseduffield/lazygit/releases/download/v{version}/lazygit_{version}_Linux_{arch}.tar.gz" \
    lazygit
```

Each of those modules shrinks to about 10 lines, and error handling becomes
consistent.

## 3. Add `ensure_bashrc_line` (or a `~/.bashrc.d/` convention)

**Done (2026-11-02):** `~/.bashrc.d/` convention. `core/bash` installs the loader via `ensure_bashrc_block` and strips the legacy appended lines (backup in `~/.bashrc.bak-setup`); modules use `bashrc_d_link`. nvm installer runs with `PROFILE=/dev/null`.

**Problem:** `sdks/go`, `sdks/node`, `sdks/rust`, `sdks/python`,
`core/oh-my-posh`, `core/global-scripts`, and `core/docker` each do
`grep -q "marker" ~/.bashrc || echo '...' >> ~/.bashrc` with ad-hoc markers.
Lines can only be appended, never updated or removed.

**Proposal (either):**
- A helper that manages a named block so a module can replace its own lines:

  ```bash
  ensure_bashrc_block go 'export PATH="$PATH:/usr/local/go/bin"'
  # writes between "# >>> setup:go >>>" and "# <<< setup:go <<<"
  ```
- Or, preferred: have the `core/bash` module add a single
  `for f in ~/.bashrc.d/*.sh; do . "$f"; done` to `.bashrc`, and have each
  module drop (symlink) a file into `~/.bashrc.d/`. Nothing edits `.bashrc`
  after the bash module. The existing `modules/sdks/*/env.sh` files could be
  reused directly for this.

## 4. Add a config-directory symlink helper or a default `configure()`

**Done (2026-11-02):** `symlink_config_dir <name> <dest>` (recursive) in `lib/util.sh`; used by lazygit and fleet. `configure()` is optional; `CONFIG_DEST` gives the default behaviour.

**Problem:** `core/lazygit`, `core/tmux`, `core/neovim`, `apps/wezterm`, and
others each loop over `config/<name>/` and symlink files one by one with their
own existence checks and warnings.

**Proposal:**
- `symlink_config_dir <name> <dest_dir>` that links every file in
  `config/<name>/` into `<dest_dir>`.
- Optionally, make `configure` default to that behaviour when a module declares
  `CONFIG_DEST="$HOME/.config/lazygit"` and defines no `configure` function.

## 5. Add a `get_arch` helper

**Done (2026-11-02):** see item 2.

**Problem:** the `case $(uname -m) in x86_64) ... aarch64) ...` block is
duplicated in every release-download module, with different output naming
(`amd64` vs `x86_64`, `arm64` vs `aarch64`).

**Proposal:** `get_arch <style>` in `lib/env.sh`, where style is `go`
(`amd64`/`arm64`) or `uname` (`x86_64`/`arm64`), used by item 2.

## 6. Make `--dry-run` useful

**Done (2026-11-02):** `dry_run_module` sources the module and prints the phases that would be called and the state of `CONFIG_REQUIRES`. The WSL skip line is added by item 8.

**Problem:** dry-run prints only "Would execute X" per module.

**Proposal:** since modules are already sourced in a subshell, source them in
dry-run too and print:
- which of `install` / `configure` / `update` would be called,
- whether the module would be skipped (WSL / GUI, see item 8),
- which `CONFIG_REQUIRES` keys it needs and whether they are set.

## 7. Fix small inconsistencies and bugs

**Done (2026-11-02):** all bullets below, plus the docker package-list hoist from 10d and the download-before-delete ordering for go/zig from 10e.

- `has_cmd` is defined in both `lib/pkg.sh` and `lib/util.sh`. Keep one.
- `modules/core/essentials/script.sh`: the package list in `install()` and
  `update()` has drifted (`bats`, `dos2unix`, `fzf`, `imagemagick` are missing
  from update). Hoist the list to a module-level variable used by both.
- `modules/apps/wezterm/script.sh`: the GPG key existence check looks at
  `/etc/apt/keyrings/wezterm-fury.gpg` but the key is written to
  `/usr/share/keyrings/wezterm-fury.gpg`, so it re-downloads every run. It also
  passes an argument to `pkg_repo_update`, which takes none. Its `update()`
  has identical branches for Arch and Ubuntu.
- `modules/sdks/go/script.sh`: downloads to `/tmp` without checking the `curl`
  result, then calls `configure()` from `install()`, so `configure` runs twice
  on a fresh install.
- Several modules define `configure() { : ; }` or log "No specific
  configuration". Make `configure` optional in the module contract, as `update`
  already is, and update `CLAUDE.md` / `README.md` accordingly.
- Modules inconsistently log their own "Configuring X..." / "Installing X..."
  step lines. Have `run_module` log the phase (install / configure / update)
  uniformly and drop the per-module lines.
- `render_template` reads the file into `content` but never uses it.
- `symlink_dir` runs `rm -rf` on the destination, which deletes a real
  directory if one exists there. Consider backing it up (`dest.bak`) or
  refusing unless it is already a symlink.

## 8. Standardize the WSL / GUI guard

**Done (2026-11-02):** `SKIP_ON_WSL=true` / `ONLY_ON_WSL=true` module flags, checked by `run_module` and dry-run, reported as `skipped (WSL)`. `mysql-workbench` and `ssh` keep `is_wsl` branches because they do partial work on WSL.

**Problem:** eight modules (`apps/gimp`, `apps/steam`, `apps/wezterm`,
`apps/mysql-workbench`, `core/docker`, `core/fonts`, `core/ssh`,
`core/onedrive-archive`) each write their own
`if is_wsl; then log_warn ...; return; fi`, with differing messages and
sometimes only in `install` but not `configure`.

**Proposal:** a module-level `GUI_ONLY=true` (or `SKIP_ON_WSL=true`) variable
checked once by `run_module`, which skips the whole module with a consistent
"skipped (GUI, WSL)" message that feeds into the summary from item 1.

## 9. Minor hygiene

- `bin/` (`cut-release`, `merge-release`, `pr`, `yeet`) and the `config/`
  layout are not described in `CLAUDE.md` or `README.md`.
- `sdks/zig` and `apps/syncthing` exist but are not listed in any intent. Add a
  comment or an `intents/optional.txt` so they are not mistaken for dead code.
- Tab/space indentation is mixed in `modules/core/essentials/script.sh`.
- Consider a `scripts/lint.sh` that runs `shellcheck` over `setup.sh`,
  `lib/*.sh`, and `modules/*/*/script.sh` as the closest thing to a test suite.

## 10. Update flow: `--update` does not refresh everything

A trace of every module's `update()` path (2026-10-26). Answer to "does
`--update` update all applications?": **no**. The misses fall into five groups.

### 10a. Arch partial-upgrade hazard (framework bug)

**Done (2026-11-02):** `--update` runs `pacman -Syu` once on Arch; per-package `pkg_update` is `pacman -S --needed`.

`main()` calls `pkg_repo_update` (`pacman -Sy`) once, then each module calls
`pkg_update <pkg>` which runs `pacman -S --noconfirm <pkg>`. On Arch that is a
partial upgrade: the database is refreshed but only some packages are
reinstalled against it. It can leave the system with mismatched shared
libraries and is explicitly unsupported by Arch.

**Fix:** on Arch, `--update` should run `pacman -Syu --noconfirm` once at the
start, and the per-package `pkg_update` should become a no-op (or
`pacman -S --needed`, which is safe after a full `-Syu`). Ubuntu's
`apt-get install --only-upgrade` per package is fine as is.

### 10b. `configure()` is skipped in update mode

**Done (2026-11-02):** `run_module` always calls `configure()` after `install`/`update`; manual calls stripped from modules.

`run_module` calls only `update()` when the module defines one. Most
`update()` bodies do not call `configure()`, so any change to `config/`
(new symlinks, edited templates, new hook files) is **not applied** on
`--update`. Affected: `core/git` (gitconfig template not re-rendered),
`core/neovim`, `core/tmux`, `core/lazygit`, `core/lazydocker`, `apps/glow`,
`apps/lazysql`, `apps/zellij`, `apps/wezterm`, `apps/taskwarrior`,
`apps/fleet` (new hooks not linked; note `apps/agent-status-collector` *does*
call configure, so the two sibling modules disagree), `core/docker`,
`sdks/go`, `sdks/zig`, `sdks/rust`, `core/oh-my-posh`.

**Fix:** have `run_module` always run `configure()` after `update()`.
Configure is already expected to be idempotent. Then strip the manual
`configure` calls from the handful of modules that do it today.

### 10c. Pinned versions only move when the repo is edited

On Ubuntu these modules install a hard-coded version and `update()` is just
"re-run install", so `--update` is a no-op until someone bumps the constant:

| Module | Pin |
| :--- | :--- |
| `core/lazygit` | `LAZYGIT_VERSION` |
| `core/lazydocker` | version constant |
| `apps/lazysql` | `LAZYSQL_VERSION` |
| `apps/glow` | `GLOW_VERSION` |
| `apps/zellij` | `ZELLIJ_VERSION` |
| `core/oh-my-posh` | `POSH_VERSION` |
| `core/neovim` | `NVIM_VERSION` (full source build) |
| `sdks/go` | `GO_VERSION` |
| `sdks/zig` | `ZIG_VERSION` |
| `core/fonts` | `JETBRAINS_FONT_VERSION` |
| `core/tmux` | `HARPOON_COMMIT` |
| `sdks/node` | nvm installer URL pinned to `v0.40.1` |

This may be intentional (reproducible machines), but it should be an explicit
policy. Options:
- Keep pins, but add a `bin/check-versions` script that queries the GitHub
  releases API for each pinned tool and prints which constants are behind.
- Or add `--latest` to `setup.sh` that lets `install_github_release` (item 2)
  resolve `latest` via the API instead of the constant.

### 10d. Modules whose `update()` does not actually update the thing

- **`core/fonts`**: `install_ubuntu` returns early if the font directory
  exists, so bumping `JETBRAINS_FONT_VERSION` never reinstalls. Needs a
  version marker file in the font dir, or compare against a stored version.
- **`sdks/python`** (Ubuntu): `pyenv update` updates pyenv itself, but the
  Python interpreter is installed in `configure()`, which update does not call.
  Python never advances. (Fixed by 10b.)
- **`sdks/node`**: `nvm install --lts` installs a new Node alongside the old
  one but does not migrate global npm packages, so after an LTS major bump
  `apps/copilot-cli` (and anything else `npm -g`) silently disappears until
  that module re-runs. Use `nvm install --lts --reinstall-packages-from=default`
  and `nvm alias default`. nvm itself is never updated on either platform
  (Arch: `pkg_install nvm` is never paired with `pkg_update nvm`).
- **`core/docker`**: update lists only `docker-ce docker-ce-cli` on Ubuntu and
  omits `containerd.io`, `docker-buildx-plugin`, `docker-compose-plugin`,
  `docker-ce-rootless-extras`; on Arch it omits `docker-rootless-extras-bin`.
  Hoist the package list to a variable shared by install and update, as with
  `core/essentials` (item 7).
- **`core/essentials`**: update list missing `bats`, `dos2unix`, `fzf`,
  `imagemagick` (item 7).
- **`core/tmux`**: `rm -f ~/.local/bin/harpoon` then `install_harpoon`
  rebuilds from source at the same pinned commit every run. Pointless churn;
  skip when the installed build already matches `HARPOON_COMMIT`.
- **`core/neovim`**: binary is pinned (10c) and Neovim plugins (lazy.nvim) are
  never synced. Consider `nvim --headless "+Lazy! sync" +qa` in update.
- **`apps/yazi`** (Ubuntu): `cargo install --force yazi-build` recompiles on
  every update even when already current. Drop `--force` (cargo skips if the
  version is unchanged) or compare `yazi --version` to the crates.io version.
- **`apps/syncthing`**: no Arch branch in install or update, silently does
  nothing there. Not in any intent today, but should log a warning.
- **`core/ansible`** (Ubuntu): calls `apt-get install --only-upgrade` directly
  instead of `pkg_update`. Works, but bypasses the abstraction.

### 10e. Failures inside update are invisible

Combined with item 1, none of the following surface in the run's outcome:
- `tar`, `make`, `sudo install`, `cargo install`, `npm install -g`, and
  `pyenv install` results are not checked in any module.
- `cd "$tmp_dir" || exit 1` in `core/neovim` and `core/tmux` exits the module
  subshell with status 1, which `run_module` discards.
- `sdks/go` and `sdks/zig` do `sudo rm -rf "$INSTALL_DIR"` **before** checking
  the download succeeded, so a failed download leaves the SDK uninstalled.
  Download and verify first, then replace.
- `curl ... | bash` installers (`apps/claude`, `sdks/node`, `sdks/python`,
  `sdks/rust`) report nothing on failure beyond the installer's own output.

### Suggested update-flow changes, in order

1. Fix the Arch partial-upgrade in `lib/pkg.sh` (10a). This is the one that
   can break a machine.
2. Always run `configure()` after `update()` in `run_module` (10b). Removes a
   whole class of "I changed the config but `--update` didn't apply it".
3. Hoist package lists into module-level variables so install and update
   cannot drift (`core/docker`, `core/essentials`).
4. Decide the pinning policy (10c) and add either a version checker or
   `--latest`.
5. Fix the individual misses in 10d, prioritising `core/fonts`, `sdks/node`
   global-package migration, and the download-before-delete ordering in
   `sdks/go` / `sdks/zig`.

## Suggested order

Items 1, 2, and 3 remove the most duplicated code and give a trustworthy
end-of-run summary. Items 5 and 8 fall out naturally while doing 2 and 1. The
bug fixes in item 7 are independent and can be done at any time. The update
flow fixes in item 10 are a separate track; 10a and 10b should go first.
