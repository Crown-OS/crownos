default:
    @just --list

# Clone components and every repository they need: just setup crownbar [crowndock ...]; no name clones all
setup *components:
    scripts/setup.sh {{components}}

# Show branch, upstream distance and local changes of each cloned component
status:
    scripts/status.sh

# Fast-forward each cloned component to its upstream
pull:
    scripts/pull.sh

# Check that Crown-OS git dependencies are patched to local clones and that Cargo resolves each component
check:
    scripts/check.sh

# Check for the tools the workspace and the ISO build need
doctor:
    scripts/doctor.sh

# Print the pacman packages CI installs for the cloned components
packages:
    scripts/packages.sh

# Add a Crown-OS repository as a submodule: just add suja, or just add lls-protocol llts-protocol
add repository directory="":
    scripts/add.sh {{repository}} {{directory}}

# Stage the submodule pointers at the tip of each remote branch (maintainers)
bump:
    scripts/bump.sh
