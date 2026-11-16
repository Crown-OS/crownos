#!/usr/bin/env bash
# Usage: setup.sh [COMPONENT...]
# Clones each COMPONENT and every sibling repository it needs, then puts each
# one on its branch. Without a COMPONENT, it clones all submodules.

# shellcheck source=scripts/lib.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/lib.sh"

declare -A needed_by
queue=("$@")
(( ${#queue[@]} )) || mapfile -t queue < <(submodule_paths)
for component in "${queue[@]}"; do needed_by[$component]=you; done

declare -A ready
missing=()
while (( ${#queue[@]} )); do
    component=${queue[0]}
    queue=("${queue[@]:1}")
    [[ -v ready[$component] ]] && continue

    if ! is_submodule "$component"; then
        missing+=("$component (needed by ${needed_by[$component]})")
        ready[$component]=missing
        continue
    fi

    is_initialized "$component" || git submodule update --init --quiet -- "$component"
    git -C "$component" symbolic-ref --quiet HEAD >/dev/null ||
        git -C "$component" switch --quiet "$(submodule_branch "$component")"
    ready[$component]=1

    while IFS= read -r dependency; do
        [[ -v needed_by[$dependency] ]] || needed_by[$dependency]=$component
        queue+=("$dependency")
    done < <(sibling_dependencies "$component")
done

cloned=$(for component in "${!ready[@]}"; do [[ ${ready[$component]} == 1 ]] && echo "$component"; done | sort)
printf 'ready (%d): %s\n' "$(wc -w <<<"$cloned")" "$(tr '\n' ' ' <<<"$cloned")"
(( ${#missing[@]} == 0 )) ||
    die "not in this workspace: ${missing[*]}; add each with: just add <repository> [directory]"
