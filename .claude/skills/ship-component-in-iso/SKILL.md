---
name: ship-component-in-iso
description: Add a new CrownOS app or service to the ISO, or change how an app is packaged, its desktop file, polkit policy or dock entry. Use when asked to ship, integrate or include a component in CrownOS.
---

# Ship a component in the ISO

Run `just setup crownos-iso <component>` first.

1. The component repository is public under Crown-OS and has two workflows:
   - `.github/workflows/ci.yml` calls `Crown-OS/.github/.github/workflows/rust.yml@main`.
   - `.github/workflows/package.yml` calls
     `Crown-OS/.github/.github/workflows/arch-package.yml@main` on a `v*` tag.
     Copy both from `crownbar/.github/workflows/`.

2. `arch-package.yml` installs only the binaries in `/usr/bin`. If the app needs
   other files:
   - For desktop files, polkit policies, D-Bus or systemd files of such an app,
     put them in `crownos-iso/packaging/crownos-base/`. Its PKGBUILD installs
     each `*.desktop` and `*.policy` file there.
   - If the app has its own `packaging/PKGBUILD` (as `crownos-files`), that
     PKGBUILD installs its files. Do not put a copy in `crownos-iso`, or pacman
     reports a file conflict.

3. Add an entry to `crownos-iso/components.toml` with
   `just crownos-iso/pin Crown-OS/<component> <tag>`. Do not edit the file by
   hand. For a component built from its PKGBUILD at the tag, set
   `pkgbuild = "packaging/PKGBUILD"` on the entry.

4. Attach only packages whose dependencies are in Arch Linux or CachyOS.

5. For a dock entry, change `crownos-iso/config/crownos/dock.ron`. Do not
   change `crownos-iso/profile/airootfs/home/crownos-live/.config`; the build
   makes it.

6. A crownui app must add the kit `window_controls()` or
   `title_bar_spacer()`, or its window has no close button.

7. Check with `just crownos-iso/check`, then build and boot with
   `just crownos-iso/build-local` and `just crownos-iso/run`.
