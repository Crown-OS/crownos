#!/usr/bin/env bash
# Usage: add.sh REPOSITORY [DIRECTORY]
# Adds Crown-OS/REPOSITORY as a submodule at DIRECTORY, which defaults to
# REPOSITORY. Use DIRECTORY when the path dependencies name another directory.

# shellcheck source=scripts/lib.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/lib.sh"

repository=${1:?add needs a Crown-OS repository name}
directory=${2:-$repository}
git submodule add --quiet --branch main "https://github.com/Crown-OS/$repository.git" "$directory"
git config --file .gitmodules "submodule.$directory.ignore" all
git add .gitmodules
echo "added $directory; commit .gitmodules and $directory"
