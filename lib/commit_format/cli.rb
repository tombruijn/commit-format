# frozen_string_literal: true

require "optparse"

module CommitFormat
  class Cli
    def initialize(args)
      @args = parse_args(args)
    end

    def execute
      parser = Parser.new(@args)
      commits = parser.commits

      formatter = Formatter.new(commits)
      formatted_commits = formatter.formatted_commits
      print_formatted_commits(formatted_commits)
    end

    private

    def print_formatted_commits(commits)
      commits_length = commits.length - 1
      commits.each_with_index do |commit, index|
        puts commit

        # Print empty line between commits
        puts if index < commits_length
      end
    end

    def parse_args(args) # rubocop:disable Metrics/MethodLength
      options = {}
      OptionParser.new do |parser|
        document_cli(parser)

        parser.separator "Options:"
        parser.on(
          "-n",
          "--max-count <number>",
          "Limit the number of commits to output"
        ) do |count|
          options[:limit] = count
        end
        parser.on(
          "-b",
          "--base-branch <branch>",
          "Select all commits since selected base branch"
        ) do |branch|
          options[:base_branch] = branch
        end
        parser.on("-v", "--version", "Print version number") do
          puts CommitFormat::VERSION
          exit 0
        end
        parser.on_tail("-h", "--help", "Show this help message") do
          puts parser
          exit 0
        end
      end.parse!(args)

      options[:init_default_branch] = `git config init.defaultbranch`.strip
      options[:selector] = args.join if args.any?
      options
    end

    def document_cli(cli) # rubocop:disable Metrics/MethodLength
      cli.banner = "Usage: commit-format [options] [commit range]"
      cli.separator ""
      cli.separator "Examples:"
      cli.separator "    commit-format"
      cli.separator "        Print all commits on a feature branch since " \
        "branching off the default branch"
      cli.separator "        Only works when not on the default branch"
      cli.separator ""
      cli.separator "    commit-format | pbcopy"
      cli.separator "        Copy the commits to the clipboard on macOS"
      cli.separator ""
      cli.separator "    commit-format HEAD~1..HEAD"
      cli.separator "        Prints the commits in the commit range"
      cli.separator ""
      cli.separator "    commit-format main..my-feature"
      cli.separator "        Prints the commits new in the 'my-feature' branch"
      cli.separator ""
      cli.separator "    commit-format -n 5"
      cli.separator "        Print the last 5 commits"
      cli.separator ""
      cli.separator "    commit-format -b main"
      cli.separator "    commit-format -b intermediate-feature-branch"
      cli.separator "        Print all new commits since selected branch"
      cli.separator ""
      cli.separator "Arguments:"
      cli.separator "    <commit range> Range of commits to format."
      cli.separator ""
    end
  end
end
