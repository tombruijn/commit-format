# frozen_string_literal: true

module CommitFormat
  class Cli
    def initialize(args)
      @args = args
      @selector = args.first || "HEAD~1...HEAD"
    end

    def execute
      parser = Parser.new(@selector)
      commits = parser.commits

      formatter = Formatter.new(commits)
      formatted_commits = formatter.formatted_commits
      commits_length = formatted_commits.length - 1
      formatted_commits.each_with_index do |commit, index|
        puts commit

        # Print empty line between commits
        puts if index < commits_length
      end
    end
  end
end
