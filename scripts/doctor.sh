#!/usr/bin/env bash
# Usage: doctor.sh
# Checks for the tools that the workspace and the ISO build need.

# shellcheck source=scripts/lib.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/lib.sh"

missing=0
check_tools() {
    local purpose=$1 tool
    shift
    for tool in "$@"; do
        command -v "$tool" >/dev/null && continue
        echo "missing for $purpose: $tool"
        missing=1
    done
}

check_tools "the workspace" git just python3 realpath
check_tools "Rust components" rustup cargo cc pkg-config
check_tools "the ISO (crownos-iso)" gh jq makepkg mkarchiso pacman-key qemu-system-x86_64 shellcheck gpg
(( missing )) || echo "all tools found"
exit "$missing"
