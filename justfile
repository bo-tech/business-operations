# List available recipes
default:
    @just --list

# A version recorded somewhere else as well - inside a Cargo.toml or a
# pyproject.toml - changes this recipe and nothing around it.
#
# Write the version the release tooling decided into VERSION.
set-version version:
    echo {{version}} > VERSION

# Called by the release tooling after set-version.
#
# Collect the changelog fragments into this version's section and remove them.
changelog version:
    towncrier build --version {{version}} --yes
