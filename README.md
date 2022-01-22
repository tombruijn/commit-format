# Commit format

Commit format is a formatter for commits to paste into a Git Pull Request
description.

## Installation

1. Clone this repository.
2. Add the `bin` directory of this repository to the Shell's PATH.

## Usage

```
# Print all commits since the default branch
commit-format

# Copy the output directly onto the clipboard on macOS
commit-format | pbcopy

# Print the range of formatted commits
commit-format main..feature-branch

# Print the last 5 commits
commit-format -n 5

# Print all commits since selected branch
commit-format -b main
commit-format -b feature-branch
```

## Features

- Turns each commit subject into a markdown heading.
- Indents all headings in the message body on level lower. Heading level 2
  becomes heading level 3, etc.

## Resources

- [Git is about communication](https://tomdebruijn.com/posts/git-is-about-communication/)
