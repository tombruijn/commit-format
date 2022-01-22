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
      OptionParser.new do |parser| # rubocop:disable Metrics/BlockLength
        parser.banner = "Usage: commit-format [options] [commit range]"
        parser.separator ""

        parser.separator "Examples:"
        parser.separator "    commit-format HEAD~1..HEAD"
        parser.separator "        Format the last commit. This is the " \
          "default behavior."
        parser.separator ""
        parser.separator "    commit-format main..branch"
        parser.separator "        Format the difference between two branches."
        parser.separator ""

        parser.separator "Arguments:"
        parser.separator "    <commit range> Range of commits to format."
        parser.separator ""

        parser.separator "Options:"
        parser.on(
          "-n",
          "--max-count <number>",
          "Limit the number of commits to output"
        ) do |count|
          options[:limit] = count
        end
        parser.on_tail("-h", "--help", "Show this help message") do
          puts parser
          exit 0
        end
      end.parse!(args)

      if args.any?
        options[:selector] = args.join
      elsif !options.key?(:limit)
        options[:selector] = "HEAD~1..HEAD"
      end
      options
    end
  end
end
