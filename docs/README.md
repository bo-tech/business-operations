# Documentation

This project uses Sphinx with Nix flakes for reproducible documentation builds.

## Local Development

From the `docs/` directory:

```bash
# Build HTML documentation
nix run .#make -- html

# Build PDF documentation
nix run .#make -- latexpdf

# Build EPUB documentation
nix run .#make -- epub

# Check that external links still resolve
nix run .#make -- linkcheck

# Enter development shell with all tools available
nix develop
```

`linkcheck` fails on a link that 404s and passes on one that redirects,
so read its report rather than its exit status: a permanent redirect is
a page that has moved and is worth following, while a temporary one
means the address in the docs is already the right one.

## Building Packages

From the repository root:

```bash
# Build HTML package
nix build ./docs#html

# Build PDF package
nix build ./docs#pdf
```

Build output will be in `result/share/doc/`.

The HTML package treats a Sphinx warning as an error, so a broken
reference fails the build rather than rendering as plain text. The
local builds above do not, so a page still being written does not fail
while you are working on it.

## Continuous integration

None ships with this repository. A pipeline that builds these docs
arrives by applying a CI overlay template for the forge that hosts it.

## Architecture Decision Records

ADRs are stored in `docs/decisions/`. To create a new ADR:

1. Copy `decisions/adr-template.md` to `decisions/NNNN-short-title.md`
2. Fill in the template sections
3. The decision log will automatically include it
