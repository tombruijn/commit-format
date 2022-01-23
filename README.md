# Commit Format

Commit Format is a formatter for commits to paste into a Git Pull Request
description.

## Installation

1. Run `gem install commit_format`

## Usage

```
# Print all commits on feature branch since branching off the default branch
# Only works when not on the default branch
commit-format

# Copy the output directly onto the clipboard on macOS
commit-format | pbcopy

# Print the range of formatted commits
commit-format HEAD~1..HEAD

# Prints the commits new in the 'my-feature' branch
commit-format main..my-feature

# Print the last 5 commits
commit-format -n 5

# Print all new commits since selected base branch
commit-format -b main
commit-format -b feature-branch
```

## Features

- Turns each commit subject into a markdown heading.
- Indents all headings in the message body on level lower. Heading level 2
  becomes heading level 3, etc.

## Development

- Run `bundle install`
- Install [mono](https://github.com/appsignal/mono).

### Tracking changes

Use mono to create a changeset per change.

```
mono changeset add
```

## Testing

```
bundle exec rspec
```

## Publishing

```
mono publish
```

## Resources

- [Git is about communication](https://tomdebruijn.com/posts/git-is-about-communication/)
