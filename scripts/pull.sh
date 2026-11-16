#!/usr/bin/env bash
# Usage: pull.sh
# Fast-forwards each cloned component to its upstream. It skips a component
# that has local changes or has diverged, and names it.

# shellcheck source=scripts/lib.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/lib.sh"

skipped=()
for component in $(initialized_submodules); do
    git -C "$component" pull --ff-only --quiet 2>/dev/null || skipped+=("$component")
done
(( ${#skipped[@]} == 0 )) || die "not fast-forwarded: ${skipped[*]}"
