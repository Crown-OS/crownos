"""Usage: python3 -I unpatched_git_dependencies.py COMPONENT...

Prints each Crown-OS git dependency that the top-level Cargo.toml of its
component does not [patch] to a local sibling clone. Exits 1 if it prints one.
"""

import pathlib
import sys
import tomllib

DEPENDENCY_TABLES = ("dependencies", "dev-dependencies", "build-dependencies")


def canonical_url(url):
    return url.lower().rstrip("/").removesuffix(".git")


def dependency_tables(manifest):
    yield from (manifest.get(name, {}) for name in DEPENDENCY_TABLES)
    yield manifest.get("workspace", {}).get("dependencies", {})
    for target in manifest.get("target", {}).values():
        yield from (target.get(name, {}) for name in DEPENDENCY_TABLES)


def unpatched_dependencies(component):
    top_level = tomllib.loads((component / "Cargo.toml").read_text())
    patched = {
        (canonical_url(url), name)
        for url, table in top_level.get("patch", {}).items()
        for name in table
    }
    for manifest_path in component.rglob("Cargo.toml"):
        if "target" in manifest_path.parts:
            continue
        for table in dependency_tables(tomllib.loads(manifest_path.read_text())):
            for name, specification in table.items():
                if not isinstance(specification, dict):
                    continue
                url = canonical_url(specification.get("git", ""))
                if "github.com/crown-os/" not in url:
                    continue
                if (url, specification.get("package", name)) not in patched:
                    yield f"{manifest_path}: {name} from {url}"


def main(components):
    findings = [
        finding
        for component in map(pathlib.Path, components)
        if (component / "Cargo.toml").exists()
        for finding in unpatched_dependencies(component)
    ]
    for finding in findings:
        print(finding)
    return 1 if findings else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
