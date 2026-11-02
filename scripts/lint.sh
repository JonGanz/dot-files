#!/bin/bash

# Closest thing to a test suite: syntax-check every script and run shellcheck
# over them when it is installed.
#
#   scripts/lint.sh          # lint everything
#   scripts/lint.sh FILE...  # lint only the given files

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." >/dev/null 2>&1 && pwd )"
cd "$DIR" || exit 1

if [ $# -gt 0 ]; then
    files=("$@")
else
    files=(setup.sh lib/*.sh modules/*/*/script.sh modules/sdks/*/env.sh config/*/bashrc.sh scripts/*.sh bin/*)
fi

status=0

for f in "${files[@]}"; do
    if ! bash -n "$f"; then
        echo "syntax error: $f" >&2
        status=1
    fi
done

if command -v shellcheck >/dev/null 2>&1; then
    # Modules are sourced into setup.sh's namespace, so lib functions and DIR
    # are defined elsewhere (SC2148: no shebang needed, SC1091: don't follow sources).
    shellcheck --shell=bash --external-sources --exclude=SC1091 "${files[@]}" || status=1
else
    echo "shellcheck not installed; only bash -n ran (install with: pkg_install shellcheck)" >&2
fi

[ $status -eq 0 ] && echo "lint ok (${#files[@]} files)"
exit $status
