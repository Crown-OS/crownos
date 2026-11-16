#!/usr/bin/env bash
# Usage: packages.sh
# Prints the pacman packages that CI installs to build the cloned components:
# the base set of Crown-OS/.github prepare-workspace plus each ci.yml input.

# shellcheck source=scripts/lib.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/lib.sh"

base_packages=(
    base-devel rustup clang cmake git github-cli jq unzip just
    wayland wayland-protocols libxkbcommon vulkan-icd-loader vulkan-headers mesa
    fontconfig freetype2 inter-font ttf-dejavu dbus bluez-libs libxcb libx11 systemd-libs
)
{
    printf '%s\n' "${base_packages[@]}"
    for component in $(initialized_submodules); do
        workflow=$component/.github/workflows/ci.yml
        if [[ -f $workflow ]]; then
            sed -nE 's/^ +packages: *"?([^"]*)"?$/\1/p' "$workflow" | tr ' ' '\n'
        fi
    done
} | grep -v '^$' | sort -u | tr '\n' ' '
echo
