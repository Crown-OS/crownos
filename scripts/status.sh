#!/usr/bin/env bash
# Usage: status.sh
# Shows the branch, the distance to its upstream and the local changes of
# each cloned component.

# shellcheck source=scripts/lib.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/lib.sh"

for component in $(initialized_submodules); do
    branch=$(git -C "$component" branch --show-current)
    distance="no upstream"
    if counts=$(git -C "$component" rev-list --left-right --count '@{upstream}...HEAD' 2>/dev/null); then
        distance=$(awk '{ printf "%s%s", ($2 ? "+" $2 " " : ""), ($1 ? "-" $1 : "") }' <<<"$counts")
    fi
    changes=$(git -C "$component" status --porcelain | wc -l)
    printf '%-26s %-22s %-10s %s\n' "$component" "${branch:-DETACHED}" "${distance:-even}" \
        "$( (( changes )) && echo "$changes changed")"
done
