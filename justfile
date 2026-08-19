# List available recipes
default:
    @just --list

# Write a version into the files this repository records it in.
# Called by the release tooling, which decides what the version is.
#
# A version recorded somewhere else as well - inside a Cargo.toml or a
# pyproject.toml - changes this recipe and nothing around it.
set-version version:
    echo {{version}} > VERSION

# Collect the changelog fragments into a section for this version and
# remove them. Called by the release tooling after set-version.
changelog version:
    towncrier build --version {{version}} --yes
