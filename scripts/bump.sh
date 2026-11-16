#!/usr/bin/env bash
# Usage: bump.sh
# Stages each cloned component's submodule pointer at the tip of its remote
# branch, so a new clone starts close to current main. Commit the result.

# shellcheck source=scripts/lib.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/lib.sh"

for component in $(initialized_submodules); do
    branch=$(submodule_branch "$component")
    git -C "$component" fetch --quiet origin "$branch"
    git update-index --cacheinfo "160000,$(git -C "$component" rev-parse FETCH_HEAD),$component"
done
git diff --cached --ignore-submodules=none --submodule=short --stat
