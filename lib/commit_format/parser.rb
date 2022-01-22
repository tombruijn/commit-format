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
      args << main_argument(options)
      args.compact.join(" ")
    end

    def main_argument(options)
      return options[:selector] if options.key?(:selector)
      return if options.key?(:limit)

      if options.key?(:base_branch)
        "#{options[:base_branch]}..HEAD"
      else
        "#{options[:init_default_branch]}..HEAD"
      end
    end
  end
end
