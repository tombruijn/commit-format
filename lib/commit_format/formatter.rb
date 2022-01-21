# frozen_string_literal: true

module CommitFormat
  class Formatter
    def initialize(commits)
      @commits = commits
    end

    def formatted_commits
      @commits.map { |commit| format_commit(commit) }
    end

    private

    def format_commit(commit)
      formatted_commit =
        commit.lines.map do |line|
          # Prepend another `#` characters to make headings one level lower
          if line.start_with?("##")
            "##{line}"
          else
            line
          end
        end.join
      # Start subject with a heading
      "## #{formatted_commit}"
    end
  end
end
