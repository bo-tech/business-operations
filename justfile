# List available recipes
default:
    @just --list

# A version recorded somewhere else as well - inside a pyproject.toml -
# changes this recipe and nothing around it.

# Write the version the release tooling decided into the files that record it.
set-version version:
    echo {{version}} > VERSION

# Collect the changelog fragments into a section for this version.
changelog version:
    towncrier build --version {{version}} --yes
