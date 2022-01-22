# frozen_string_literal: true

module CommitFormat
  class Parser
    SEPARATOR = "# ------------------------ COMMIT >! ------------------------"

    def initialize(options)
      @options = options
    end

    def commits
      log_output =
        `git log --reverse --pretty="#{SEPARATOR}%n%B" #{arguments(@options)}`
      log_output
        .split(SEPARATOR)
        .map(&:strip)
        .reject { |commit| commit.length.zero? }
    end

    private

    def arguments(options)
      args = []
      args << "--max-count=#{options[:limit]}" if options.key?(:limit)
      args << options[:selector] if options.key?(:selector)
      args.join(" ")
    end
  end
end
