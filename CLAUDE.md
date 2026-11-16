# CrownOS workspace

This repository contains each CrownOS component as a Git submodule, side by
side. Read `CONTRIBUTING.md` for the setup. The workspace commands are in the
`justfile`: `just setup <component>`, `just status`, `just pull`, `just check`.

## Layout rules

- Each submodule is an independent repository. Make commits in the submodule,
  not in the workspace root. The submodule pointers are not version pins;
  `crownos-iso/components.toml` pins the releases that go into the ISO.
- Components use `path = "../<sibling>"` dependencies. Each Crown-OS
  `git = "https://github.com/crown-os/<repo>"` dependency also needs a
  `[patch."https://github.com/crown-os/<repo>"]` entry in the top-level
  `Cargo.toml` of the component, with the path to the local clone. `just check`
  finds a missing entry.
- CI clones the siblings from GitHub `main`. Merge a library change (crownui,
  crownos-config, crownos-ipc ...) on its `main` before the component that uses it.
- If a sibling is not cloned, run `just setup <component>`. If it is not in the
  workspace, add it with `just add <repository> [directory]`.

## Code rules

- Use meaningful, complete, self-explanatory names for variables, functions,
  traits and modules.
- Follow idiomatic Rust. Use a Cargo workspace for each Rust project and keep
  each layer in a separate, composable crate.
- Keep the solution simple: the best performance with the fewest lines of code
  that stay readable.
- Profile each component to optimize for performance and a low memory footprint.
  Use hardware acceleration (GPU, SIMD) where it measurably improves performance.
- Do not write comments that only repeat the code. If code needs a comment to be
  understood, change the code.
- Do not put all functions and traits in one file. Make separate files and modules.
- Keep utility functions in `<crate-name>/utils/<name>.rs`, one module for each utility.
- Follow the folder structure that is already in the repository.
- Prefer borrowing over cloning. Use `Cow<str>` when ownership is conditional.
  Minimize lifetime annotations.
- Do not use `unwrap` and `expect`. Use `thiserror` for library error types and
  `anyhow` for application error handling.
- crownui windows use client-side decorations. Each app must add the kit
  `window_controls()` or `title_bar_spacer()`, or the window has no close button.

## Commits and docs

- Sign off each commit with `git commit -s`. The Crown-OS repositories require
  the DCO `Signed-off-by` line.
- Write technical docs and comments in ASD-STE100 Simplified Technical English.
