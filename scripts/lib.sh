#!/usr/bin/env bash
# shellcheck shell=bash

set -euo pipefail
shopt -s nullglob

workspace_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
cd "$workspace_root"

die() {
    printf 'error: %s\n' "$*" >&2
    exit 1
}

submodule_paths() {
    git config --file .gitmodules --get-regexp '^submodule\..*\.path$' | awk '{ print $2 }'
}

is_submodule() {
    git config --file .gitmodules --get "submodule.$1.path" >/dev/null
}

is_initialized() {
    [[ -e $1/.git ]]
}

initialized_submodules() {
    local path
    for path in $(submodule_paths); do
        is_initialized "$path" && echo "$path"
    done
}

submodule_branch() {
    git config --file .gitmodules --get "submodule.$1.branch" || echo main
}

sibling_dependencies() {
    local component=$1 manifest relative
    {
        git config --file .gitmodules --get "submodule.$component.requires" | tr ' ' '\n' || true
        while IFS= read -r -d '' manifest; do
            sed -nE 's/.*path *= *"([^"]+)".*/\1/p' "$manifest" | while IFS= read -r relative; do
                realpath -m --relative-to=. "$(dirname "$manifest")/$relative" | cut -d/ -f1
            done
        done < <(find "$component" -name Cargo.toml -not -path '*/target/*' -print0)
    } | grep -vxF -e "$component" -e '' -e '..' | sort -u
}
