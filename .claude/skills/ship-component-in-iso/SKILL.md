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
     put them in `crownos-iso/packaging/crownos-base/`: a desktop file in
     `applications/`, the other files in a folder for the feature, installed by
     a `_package_<feature>` function of its PKGBUILD.
   - If the app has its own `packaging/PKGBUILD` (as `crownos-files`), that
     PKGBUILD installs its files. Do not put a copy in `crownos-iso`, or pacman
     reports a file conflict.

3. Add an entry to `crownos-iso/components.toml` with
   `just crownos-iso/pin Crown-OS/<component> <tag>`. Do not edit the file by
   hand. For a component built from its PKGBUILD at the tag, set
   `pkgbuild = "packaging/PKGBUILD"` on the entry. Set `install` to say where it
   goes: `system` (default: live image and installed systems), `live` (live
   image only), `installed` (installed systems only; downloaded during the
   install and never in the ISO: use it for large apps such as AI features) or
   `optional` (only in the repository).

4. Attach only packages whose dependencies are in Arch Linux or CachyOS. A
   third-party package goes in one file of `crownos-iso/packages/`:
   `desktop.list` for the desktop on the live image and installed systems; the
   header of each other list says where it goes.

5. Defaults and services follow system updates only through files that a
   package owns:
   - For a dock entry or another default setting, change
     `crownos-iso/defaults/<section>.ron`. crownos-base installs it to
     `/usr/share/crownos/defaults/` for the live image and installed systems.
     For a value that only the live image needs, add only that key to
     `crownos-iso/defaults/live/<section>.ron`. Do not put a copy in `/etc/skel`
     or in a home: each user's file shows the defaults as comments.
   - For the config of another program, put it in `crownos-iso/dotfiles/` at
     the path it installs to.
   - For a program that must start with the desktop, add it to
     `session_startup` in `crownos-iso/defaults/compositor.ron`, not to
     `startup`.
   - For a system service, add an `enable` line to
     `crownos-iso/packaging/crownos-base/systemd/80-crownos.preset`. The installer and
     `crownos-updated` enable new preset lines; `systemctl enable` in a script
     reaches only new installs. A release that adds a unit needs
     `restart = "soft-reboot"` or `"reboot"`.
   - For a user service, add a `default.target.wants` link in the crownos-base
     PKGBUILD, as `crownos-automount` does.
   - To remove a package from installed systems, add it to `retired` in
     `crownos-iso/releases/<version>/release.toml`.

6. A crownui app must add the kit `window_controls()` or
   `title_bar_spacer()`, or its window has no close button.

7. Check with `just crownos-iso/check`, then build and boot with
   `just crownos-iso/build-local` and `just crownos-iso/run`.
