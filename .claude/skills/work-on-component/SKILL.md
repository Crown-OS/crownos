---
name: work-on-component
description: Clone, build, test and change a CrownOS component in this workspace, including changes that span a library and its users. Use when asked to work on, fix, build or test crownbar, crowndock, crownui or any other submodule.
---

# Work on a component

1. Clone the component and the repositories it needs:

   ```sh
   just setup <component>
   ```

   If it reports a repository as "not in this workspace", add it with
   `just add <repository> [directory]` and run `just setup` again. Tell the
   user if that repository is not on GitHub.

2. Work in `<component>/`. Each submodule is its own Git repository on its
   `main` branch. Make branches and commits there, never in the workspace root.

3. Run the CI checks in the component directory:

   ```sh
   cargo fmt --check
   cargo build --all-targets --locked
   cargo clippy --all-targets -- -D warnings
   CROWN_CONFIG_DIR=/tmp/crownos-test cargo test
   ```

   CI sets `CROWN_CONFIG_DIR` so tests do not touch `~/.config/crownos`.
   crownotify tests need `dbus-run-session -- cargo test -- --test-threads=1`.
   If a system library is missing, compare with `just packages`.

4. When you add a `git = "https://github.com/crown-os/<repo>"` dependency, also
   add `[patch."https://github.com/crown-os/<repo>"]` with
   `<crate> = { path = "../<repo>/<crate-dir>" }` to the top-level
   `Cargo.toml` of the component. Then run `just check` from the workspace root.

5. For a change in a library (crownui, crownos-config, crownos-ipc,
   crownos-protocols, crownos-plugins ...) and in a component that uses it:
   - Build each dependent component that is cloned. `just status` lists them;
     `grep -l '../<library>' */Cargo.toml` finds the users.
   - Merge the library change on its GitHub `main` first. CI of the component
     clones the library from `main` and builds `--locked`, so the component
     fails until then.

6. Commit with `git commit -s` (DCO sign-off is required).
