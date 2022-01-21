# frozen_string_literal: true

module CommitFormat
  class Parser
    SEPARATOR = "# ------------------------ COMMIT >! ------------------------"

    def initialize(selector)
      @selector = selector
    end

    def commits
      log_output = `git log --reverse --pretty="#{SEPARATOR}%n%B" #{@selector}`
      log_output
        .split(SEPARATOR)
        .map(&:strip)
        .reject { |commit| commit.length.zero? }
    end
  end
end
