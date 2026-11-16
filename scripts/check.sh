#!/usr/bin/env bash
# Usage: check.sh
# Fails if a Crown-OS git dependency has no local [patch], or if Cargo cannot
# resolve a cloned component with its committed Cargo.lock.

# shellcheck source=scripts/lib.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/lib.sh"

mapfile -t components < <(initialized_submodules)
failed=0
python3 -I scripts/unpatched_git_dependencies.py "${components[@]}" || failed=1

for component in "${components[@]}"; do
    [[ -f $component/Cargo.toml ]] || continue
    if error=$(cd "$component" && cargo metadata --locked --format-version 1 2>&1 >/dev/null); then
        printf '%-26s ok\n' "$component"
    else
        printf '%-26s %s\n' "$component" "$(grep -m1 -E '^error' <<<"$error")"
        failed=1
    fi
done
exit "$failed"
