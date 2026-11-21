#!/usr/bin/env bash
# Usage: run.sh [-r] COMPONENT[/BINARY] [ARGUMENT...]
# Builds and runs a binary of a cloned component with cargo run. Without
# BINARY, it runs the binary with the name of the component, or the only
# binary of the component. It gives each ARGUMENT to the binary. -r builds
# with --release.

# shellcheck source=scripts/lib.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/lib.sh"

cargo_flags=()
if [[ ${1:-} == -r ]]; then
    cargo_flags=(--release)
    shift
fi
(( $# )) || die "usage: just run [-r] COMPONENT[/BINARY] [ARGUMENT...]"
target=${1%/}
shift
component=${target%%/*}
requested_binary=${target#"$component"}
requested_binary=${requested_binary#/}

[[ -f $component/Cargo.toml ]] || die "$component is not a cloned Rust component; run: just setup $component"

cd "$component"
read -r package binary < <(
    cargo metadata --no-deps --format-version 1 |
        python3 -I "$workspace_root/scripts/select_binary.py" "$component" ${requested_binary:+"$requested_binary"}
) || exit 1
exec cargo run "${cargo_flags[@]}" --package "$package" --bin "$binary" -- "$@"
