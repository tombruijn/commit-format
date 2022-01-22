# Commit format

Commit format is a formatter for commits to paste into a Git Pull Request
description.

## Installation

1. Run `gem install commit_format`

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
