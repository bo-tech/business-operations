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
release rather than reading the commits:

```markdown
A generated repository can release more than once
```

Write the entry without a leading `-`. towncrier adds the bullet when it
collects the fragments, so a dash here renders as `- - The entry`.

**Do not delete this file.** A release removes every fragment it
consumed, git does not track an empty directory, and the next change
would then have nowhere to write.
