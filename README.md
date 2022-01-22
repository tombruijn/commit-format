# Commit format

Commit format is a formatter for commits to paste into a Git Pull Request description.

## Installation

1. Clone this repository.
2. Add the `bin` directory of this repository to the Shell's PATH.

## Usage

```
# Print the range of formatted commits
commit-format main..feature-branch

# Copy the output directly onto the clipboard
commit-format main..feature-branch | pbcopy

# Print the last 5 commits
commit-format -n 5
```

## Features

- Turns the subject into a markdown heading
- Indents all headings in the message body on level lower. Heading level 2 becomes heading level 3.

## Resources

- [Git is about communication](https://tomdebruijn.com/posts/git-is-about-communication/)
