---
bump: "minor"
type: "add"
---

Add paragraph flag to format message body output to join paragraph lines. This is similar to how GitHub now formats Pull Requests with a single commit. Use `-p`/`--paragraph` to use this feature.

Given a commit with the message body of two lines:

```
Line 1.
Line 2.

- Item 1.
- Item 2.
```

This is output as:

```
Line 1. Line 2.

- Item 1.
- Item 2.
```

Other Markdown syntax, like tables, lists, code blocks, etc. are all kept in their original format in the output. Their lines are not joined into one line.
