# Changelog fragments

One file per change. A release collects them into a version section in
`CHANGELOG.md` and removes them, so nothing here is edited by two
branches at once and a merge never conflicts over the changelog.

Name a fragment `<slug>.<type>.md`, where the type is one of `added`,
`changed`, `deprecated`, `removed`, `fixed` or `security`. Prefix the
slug with `+` when there is no issue number behind it — without the
prefix, the part before the type is read as an issue reference.

```text
changelog.d/+reopen-unreleased.fixed.md
```

The content is the entry itself, written for someone consuming a
release rather than reading the commits. Write in the present tense,
describing the repository as it now is rather than what you did to it.
A fix usually reads as the absence of the problem.

```markdown
A generated repository can release more than once.
```

Start the entry with a capital and end it with a full stop. Keep it to
a few lines. One sentence is often enough; add more only to say what
was wrong before and why it mattered.

```markdown
A first release no longer stalls on the flake files. Nix will not
evaluate an untracked `flake.nix`, so the release shell could not be
entered in a fresh clone.
```

Write the entry without a leading `-`. towncrier adds the bullet when it
collects the fragments, so a dash here renders as `- - The entry`.

Order inside a section is towncrier's, not the order the fragments were
written. Entries carrying an issue reference come first, sorted by it;
`+` entries come last, sorted alphabetically by their own text. So the
entry you consider most important cannot be put at the top by naming
its file — write the section so that the order does not carry meaning.

**Do not delete this file.** A release removes every fragment it
consumed, git does not track an empty directory, and the next change
would then have nowhere to write.
