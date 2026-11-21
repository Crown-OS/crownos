"""Usage: cargo metadata --no-deps --format-version 1 | python3 -I select_binary.py COMPONENT [BINARY]

Prints the package and the binary that `just run COMPONENT[/BINARY]` starts.
Without BINARY, it selects the binary with the name of the component, or the
only binary of the default workspace members. Exits 1 and lists the binaries
if it cannot select one.
"""

import json
import sys


def binaries(metadata):
    default_members = set(metadata.get("workspace_default_members", []))
    for package in metadata["packages"]:
        for target in package["targets"]:
            if "bin" in target["kind"]:
                yield package["name"], target["name"], package["id"] in default_members


def select(component, requested_binary, available):
    if requested_binary:
        return [entry for entry in available if entry[1] == requested_binary]
    named_like_component = [entry for entry in available if entry[1] == component]
    return named_like_component or [entry for entry in available if entry[2]]


def main():
    component, requested_binary = sys.argv[1], (sys.argv[2:] or [None])[0]
    available = list(binaries(json.load(sys.stdin)))
    selected = select(component, requested_binary, available)
    if len(selected) == 1:
        package, binary, _ = selected[0]
        print(package, binary)
        return 0
    if not available:
        print(f"error: {component} has no binaries", file=sys.stderr)
        return 1
    wanted = f"binary {requested_binary}" if requested_binary else "one binary"
    print(f"error: cannot select {wanted} in {component}; run one of:", file=sys.stderr)
    for _, binary, _ in available:
        print(f"  just run {component}/{binary}", file=sys.stderr)
    return 1


if __name__ == "__main__":
    sys.exit(main())
