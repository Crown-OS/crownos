# Set up a CrownOS development environment

This guide tells you how to get the CrownOS source code, build a component and
send a change. CrownOS has one Git repository for each component. This
workspace repository contains each one as a Git submodule, side by side.

## 1. Know the layout

```text
crownos/
├── crownbar/          one component repository (a submodule)
├── crownui/           a library that many components use (a submodule)
├── crownos-iso/       builds the ISO from released components (a submodule)
├── ...
├── justfile           the workspace commands
└── scripts/
```

The components refer to each other with relative paths, for example
`path = "../crownui/crownui"`. Each component also has a `[patch]` section that
changes its Crown-OS `git = "https://github.com/crown-os/..."` dependencies to
the local clones. Thus, the side-by-side layout is necessary. CI uses the same
layout: it clones each `../<sibling>` from the `main` branch on GitHub.

The submodule pointers in this repository are not version pins. Each component
works on its `main` branch. `crownos-iso/components.toml` is the only file that
pins the component releases that go into the ISO.

## 2. Install the tools

You need Arch Linux or CachyOS. CI builds on Arch Linux, and the ISO build
needs `pacman`, `makepkg` and `archiso`.

1. Install the base tools:

   ```sh
   sudo pacman -S --needed git just python rustup
   rustup toolchain install 1.97.1 --component rustfmt clippy rust-src
   ```

   `rust-toolchain.toml` in this repository selects Rust 1.97.1. Some
   components have their own `rust-toolchain.toml`, which takes precedence.

2. To build the ISO, install these tools also:

   ```sh
   sudo pacman -S --needed github-cli jq archiso qemu-desktop edk2-ovmf shellcheck gnupg
   gh auth login
   ```

## 3. Get the source code

1. Clone the workspace. Do not clone the submodules yet:

   ```sh
   git clone https://github.com/Crown-OS/crownos.git
   cd crownos
   ```

2. Clone the components that you want to work on. `just setup` also clones
   every repository that each component needs, and puts each repository on its
   branch:

   ```sh
   just setup crownbar            # crownbar and its dependencies only
   just setup crownotify crownpaper
   just setup                     # all components
   ```

   You can run `just setup` again at any time. It does not change a repository
   that is already cloned.

3. Install the system libraries that CI installs for the cloned components:

   ```sh
   sudo pacman -S --needed $(just packages)
   ```

4. Make sure that no tool is missing:

   ```sh
   just doctor
   ```

## 4. Build and test a component

Work in the directory of the component. Use the same commands as CI:

```sh
cd crownbar
cargo fmt --check
cargo build --all-targets --locked
cargo clippy --all-targets -- -D warnings
cargo test
```

Before you send a change, run `just check` from the workspace root. It does
these checks on each cloned component:

- Each Crown-OS `git` dependency has a `[patch]` to the local clone.
- Cargo can resolve the dependencies with the committed `Cargo.lock`.

## 5. Change more than one repository

CI clones the sibling repositories from GitHub `main`, not from your disk. A
change that is necessary in a library (for example `crownui`, `crownos-config`
or `crownos-ipc`) must merge into the `main` branch of that library first.
Then, send the change for the component that uses it. If you send the two
changes in the opposite sequence, CI for the component fails.

## 6. Keep the repositories current

```sh
just status    # branch, distance to upstream and local changes of each clone
just pull      # fast-forward each clone; it names the clones it cannot update
```

Each component is a usual Git repository. Make branches, commits and pull
requests in the component directory, not in the workspace root.

## 7. Send a change

1. Fork the component on GitHub and add the fork as a remote of that component.
2. Make a branch and commit your change. Sign off each commit with `git commit -s`.
   The Crown-OS repositories require the DCO `Signed-off-by` line.
3. Push the branch to your fork and open a pull request on the component
   repository.

## 8. Build the ISO

Run the `crownos-iso` recipes from the workspace root with `just crownos-iso/<recipe>`:

```sh
just setup crownos-iso
just crownos-iso/check
just crownos-iso/build-local    # uses the crownos-installer clone in this workspace
just crownos-iso/run
```

`crownos-iso/README.md` and `crownos-iso/docs/publishing.md` give more data.

## 9. Add a repository to the workspace

If `just setup` tells you that a repository is not in this workspace, add it:

```sh
just add <repository> [directory]
```

Use `directory` only when the path dependencies use a different name than the
GitHub repository. Then commit `.gitmodules` and the new directory.
