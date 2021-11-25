# frozen_string_literal: true

class CommitFormat
  SEPARATOR = "# ------------------------ COMMIT >! ------------------------"

  def initialize(args)
    @selector = args.first || "HEAD~1...HEAD"
  end

  def parse_commits
    log_output = `git log --reverse --pretty="#{SEPARATOR}%n%B" #{@selector}`
    log_output
      .split(SEPARATOR)
      .map(&:strip)
      .reject { |commit| commit.length.zero? }
  end

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

  def execute
    commits = parse_commits
    commits_length = commits.length - 1
    commits.each_with_index do |commit, index|
      puts format_commit(commit)

      # Print empty line between commits
      puts if index < commits_length
    end
  end
end
