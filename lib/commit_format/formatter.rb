# frozen_string_literal: true

module CommitFormat
  class Formatter
    def initialize(commits, options = {})
      @commits = commits
      @paragraph = options[:paragraph]
    end

    def formatted_commits
      @commits.map do |commit|
        if @paragraph
          format_commit_as_paragraphs(commit)
        else
          format_commit(commit)
        end
      end
    end

    private

    def format_commit_as_paragraphs(commit)
      message = Message.new
      lines = commit.split("\n")
      subject = "## #{lines.shift}\n"
      lines.each do |line|
        message.line line
      end
      message.end!
      "#{subject}#{message}"
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

    class Message
      def initialize
        @lines = []
        @paragraph = []
        @code_block = false
      end

      def line(string) # rubocop:disable Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
        if code_block_fence?(string)
          new_paragraph
          code_block!
          lines << string
          return
        elsif code_block?
          lines << string
          return
        elsif string.empty? # Line break
          new_paragraph
          line_break
          return
        elsif string.start_with? "#"
          write_paragraph
          heading string
          return
        elsif fixed_line?(string)
          new_paragraph
          lines << string
          return
        elsif heading_line?(string)
          write_paragraph
          lines << string
          return
        end

        paragraph << string
        # Line with line break and the end
        write_paragraph if string.end_with? "  "
      end

      def end!
        write_paragraph
      end

      def to_s
        @lines.join("\n")
      end

      private

      LINE_BREAK = ""

      attr_reader :lines, :paragraph

      def new_paragraph
        write_paragraph if paragraph.any?
      end

      def write_paragraph
        return unless paragraph.any?

        lines << paragraph.join(" ")
        clear_paragraph!
      end

      def heading(string)
        lines << "##{string}"
      end

      HEADING_LINE_CHARS = ["=", "-"].freeze

      def heading_line?(string)
        line = string.strip
        uniq_chars = line.chars.uniq
        return false if uniq_chars.length > 1

        HEADING_LINE_CHARS.include?(uniq_chars.first)
      end

      def fixed_line?(string)
        string.start_with?("  ") || # Indented line
          string.start_with?("\t") || # Indented line
          string.start_with?("- ") || # Unordered list item
          string.start_with?("* ") || # Unordered list item
          string.start_with?("|") || # Table
          string.start_with?("> ") || # Blockquote
          string.start_with?(/\d+\. /) # Numbered list item
      end

      def clear_paragraph!
        @paragraph = []
      end

      def code_block?
        @code_block
      end

      def code_block!
        @code_block = !@code_block
      end

      def code_block_fence?(string)
        string.start_with?("```") || string.start_with?("~~~")
      end

      def line_break
        lines << LINE_BREAK
      end
    end
  end
end
