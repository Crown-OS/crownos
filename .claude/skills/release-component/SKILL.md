---
name: release-component
description: Release a new version of a CrownOS component and pin it for the ISO. Use when asked to tag, release, publish or bump a component version, or to update components.toml.
---

# Release a component

Ask the user before you push a tag: a tag publishes a release.

1. Make sure that the work is on `main` of the component and that CI is green:
   `gh run list -R Crown-OS/<component> --branch main --limit 1`.
2. Choose the next version from the last tag (`git describe --tags --abbrev=0`).
   The package version comes from the tag, not from `Cargo.toml`.
3. Tag and push: `git tag v<version> && git push origin v<version>`. The
   `package.yml` (or `release.yml`) workflow builds the Arch package and
   attaches it to the release. Wait until it is complete:
   `gh run watch -R Crown-OS/<component>`.
4. Pin the release for the ISO from the workspace root:

   ```sh
   just crownos-iso/pin Crown-OS/<component> v<version>
   just crownos-iso/gate
   ```

   `gate` fails if a pinned component's `main` is ahead of its pinned tag.
   Commit the `components.toml` change in `crownos-iso` with `git commit -s`.
5. For the ISO itself, the sequence is: tag `crownos-installer`, run the manual
   ISO test (`gh workflow run release.yml -R Crown-OS/crownos-iso`), and tag
   `crownos-iso` only when that run is green. Only maintainers do this step.
