# frozen_string_literal: true

RSpec.describe CommitFormat::Cli do
  describe "with --version flag" do
    it "prints the version number" do
      output = run_version
      expect(output.strip).to eql(CommitFormat::VERSION)
    end
  end

  describe "without an argument" do
    it "formats all commits to main branch" do
      test_dir = "without_argument"
      prepare_repository test_dir do
        create_commit "Commit subject 1", "Commit message body.\nSecond line."
        checkout_branch "my-branch"
        create_commit "Commit subject 2", "Commit message body.\nSecond line."
        create_commit "Commit subject 3", "Commit message body.\nSecond line."
      end

      output = run(test_dir)
      expect(output).to eql(<<~OUTPUT)
        ## Commit subject 2

        Commit message body.
        Second line.

        ## Commit subject 3

        Commit message body.
        Second line.
      OUTPUT
    end

    it "indents headings by one level" do
      test_dir = "indent_headings"
      prepare_repository test_dir do
        create_commit "Commit subject 1", "Commit message body.\nSecond line."
        checkout_branch "my-branch"
        create_commit "Commit subject 2", <<~MESSAGE
          Commit message body.
          Second line.

          ## Heading 2

          Hello heading.
          Other line.
        MESSAGE
      end

      output = run(test_dir)
      expect(output).to eql(<<~OUTPUT)
        ## Commit subject 2

        Commit message body.
        Second line.

        ### Heading 2

        Hello heading.
        Other line.
      OUTPUT
    end
  end

  describe "with --paragraph flag" do
    it "formats all commits to main branch as paragraphs" do
      test_dir = "paragraph_flag"
      prepare_repository test_dir do
        create_commit "Commit subject 1", "Commit message body.\nSecond line."
        checkout_branch "my-branch"
        create_commit "Commit subject 2",
          <<~MESSAGE
            Commit message body.
            Second line.
          MESSAGE
      end

      output = run(test_dir, ["--paragraph"])
      expect(output).to eql(<<~OUTPUT)
        ## Commit subject 2

        Commit message body. Second line.
      OUTPUT
    end

    it "indents headings by one level" do
      test_dir = "paragraph_flag_headings"
      prepare_repository test_dir do
        create_commit "Commit subject 1", "Commit message body.\nSecond line."
        checkout_branch "my-branch"
        create_commit "Commit subject 2",
          <<~MESSAGE
            Commit message body.
            Second line.

            ## Heading 2

            Hello heading.
            ## Heading 2
            Other line.
          MESSAGE
      end

      output = run(test_dir, ["--paragraph"])
      expect(output).to eql(<<~OUTPUT)
        ## Commit subject 2

        Commit message body. Second line.

        ### Heading 2

        Hello heading.
        ### Heading 2
        Other line.
      OUTPUT
    end

    it "keeps underline heading formatting" do
      test_dir = "paragraph_flag_headings_underline"
      prepare_repository test_dir do
        create_commit "Commit subject 1", "Commit message body.\nSecond line."
        checkout_branch "my-branch"
        create_commit "Commit subject 2",
          <<~MESSAGE
            Commit message body.

            Heading 2
            ---

            End of message.
          MESSAGE
      end

      output = run(test_dir, ["--paragraph"])
      expect(output).to eql(<<~OUTPUT)
        ## Commit subject 2

        Commit message body.

        Heading 2
        ---

        End of message.
      OUTPUT
    end

    it "keeps indented lines" do
      test_dir = "paragraph_flag_indented"
      prepare_repository test_dir do
        create_commit "Commit subject 1", "Commit message body.\nSecond line."
        checkout_branch "my-branch"
        create_commit "Commit subject 2",
          <<~MESSAGE
            Commit message body.

              Hello code.
              Other line.

            Paragraph line.

            \tNew indented
            \tblock.
          MESSAGE
      end

      output = run(test_dir, ["--paragraph"])
      expect(output).to eql(<<~OUTPUT)
        ## Commit subject 2

        Commit message body.

          Hello code.
          Other line.

        Paragraph line.

        \tNew indented
        \tblock.
      OUTPUT
    end

    it "starts a new line after a line ending with two spaces" do
      test_dir = "paragraph_flag_end_spaces"
      prepare_repository test_dir do
        create_commit "Commit subject 1", "Commit message body.\nSecond line."
        checkout_branch "my-branch"
        create_commit "Commit subject 2", <<~MESSAGE, :verbatim => true
          Commit message body.
          Second line.

          Start line.
          Hello line.\x20\x20
          Next line.

          Footer
        MESSAGE
      end

      output = run(test_dir, ["--paragraph"])
      expect(output).to eql(<<~OUTPUT)
        ## Commit subject 2

        Commit message body. Second line.

        Start line. Hello line.\x20\x20
        Next line.

        Footer
      OUTPUT
    end

    it "keeps list formatting" do
      test_dir = "paragraph_flag_lists"
      prepare_repository test_dir do
        create_commit "Commit subject 1", "Commit message body.\nSecond line."
        checkout_branch "my-branch"
        create_commit "Commit subject 2",
          <<~MESSAGE
            Commit message body.
            Second line.

            - Hello list.
              Other line.
            - Test
            * Second item.
              * Third item.

            1. First item.
            2. Second item.
              1. Third item.
            - End list

            Footer
          MESSAGE
      end

      output = run(test_dir, ["--paragraph"])
      expect(output).to eql(<<~OUTPUT)
        ## Commit subject 2

        Commit message body. Second line.

        - Hello list.
          Other line.
        - Test
        * Second item.
          * Third item.

        1. First item.
        2. Second item.
          1. Third item.
        - End list

        Footer
      OUTPUT
    end

    it "keeps tables formatting" do
      test_dir = "paragraph_flag_tables"
      prepare_repository test_dir do
        create_commit "Commit subject 1", "Commit message body.\nSecond line."
        checkout_branch "my-branch"
        create_commit "Commit subject 2",
          <<~MESSAGE
            Commit message body.
            Second line.

            | Heading 1 | Heading 2 |
            | --------- |:---------:|
            | lorem     | lorem     |
            | lorem     | lorem     |
            | lorem     | lorem     |

            Footer
          MESSAGE
      end

      output = run(test_dir, ["--paragraph"])
      expect(output).to eql(<<~OUTPUT)
        ## Commit subject 2

        Commit message body. Second line.

        | Heading 1 | Heading 2 |
        | --------- |:---------:|
        | lorem     | lorem     |
        | lorem     | lorem     |
        | lorem     | lorem     |

        Footer
      OUTPUT
    end

    it "keeps blockquotes formatting" do
      test_dir = "paragraph_flag_blockquotes"
      prepare_repository test_dir do
        create_commit "Commit subject 1", "Commit message body.\nSecond line."
        checkout_branch "my-branch"
        create_commit "Commit subject 2",
          <<~MESSAGE
            Commit message body.
            Second line.

            > I am a quote
            > I am another quote

            > Second quote

            Footer
          MESSAGE
      end

      output = run(test_dir, ["--paragraph"])
      expect(output).to eql(<<~OUTPUT)
        ## Commit subject 2

        Commit message body. Second line.

        > I am a quote
        > I am another quote

        > Second quote

        Footer
      OUTPUT
    end

    it "keeps code blocks formatting" do
      test_dir = "paragraph_flag_code_blocks"
      prepare_repository test_dir do
        create_commit "Commit subject 1", "Commit message body.\nSecond line."
        checkout_branch "my-branch"
        create_commit "Commit subject 2",
          <<~MESSAGE
            Commit message body.
            Second line.

            ```ruby
            Hello code.
            # Comment line
            Other line.
            ```

            ~~~ruby
            Hello code.
            Other line.
            ~~~

            New paragraph.
            With new line.
          MESSAGE
      end

      output = run(test_dir, ["--paragraph"])
      expect(output).to eql(<<~OUTPUT)
        ## Commit subject 2

        Commit message body. Second line.

        ```ruby
        Hello code.
        # Comment line
        Other line.
        ```

        ~~~ruby
        Hello code.
        Other line.
        ~~~

        New paragraph. With new line.
      OUTPUT
    end

    it "keeps horizontal line formatting" do
      test_dir = "paragraph_flag_horizontal_line"
      prepare_repository test_dir do
        create_commit "Commit subject 1", "Commit message body.\nSecond line."
        checkout_branch "my-branch"
        create_commit "Commit subject 2",
          <<~MESSAGE
            Commit message body.

            ---

            New paragraph.
          MESSAGE
      end

      output = run(test_dir, ["--paragraph"])
      expect(output).to eql(<<~OUTPUT)
        ## Commit subject 2

        Commit message body.

        ---

        New paragraph.
      OUTPUT
    end
  end

  context "with --base-branch argument" do
    it "formats all commits since the base branch" do
      test_dir = "base_branch"
      prepare_repository test_dir do
        create_commit "Commit subject 1", "Commit message body.\nSecond line."
        checkout_branch "branch1"
        create_commit "Commit subject 2", "Commit message body.\nSecond line."
        checkout_branch "branch2"
        create_commit "Commit subject 3", "Commit message body.\nSecond line."
        create_commit "Commit subject 4", "Commit message body.\nSecond line."
      end

      output = run(test_dir, ["--base-branch=branch1"])
      expect(output).to eql(<<~OUTPUT)
        ## Commit subject 3

        Commit message body.
        Second line.

        ## Commit subject 4

        Commit message body.
        Second line.
      OUTPUT
    end
  end

  describe "with --max-count argument" do
    it "--max-count 1 formats a single commit" do
      test_dir = "option_max_count_1"
      prepare_repository test_dir do
        create_commit "Commit subject 1", "Commit message body.\nSecond line."
        create_commit "Commit subject 2", "Commit message body.\nSecond line."
      end

      output = run(test_dir, ["--max-count=1"])
      expect(output).to eql(<<~OUTPUT)
        ## Commit subject 2

        Commit message body.
        Second line.
      OUTPUT
    end

    it "--max-count 2 formats multiple commits" do
      test_dir = "option_max_count_2"
      prepare_repository test_dir do
        create_commit "Commit subject 1", "Commit message body.\nSecond line."
        create_commit "Commit subject 2", "Commit message body.\nSecond line."
      end

      output = run(test_dir, ["--max-count=2"])
      expect(output).to eql(<<~OUTPUT)
        ## Commit subject 1

        Commit message body.
        Second line.

        ## Commit subject 2

        Commit message body.
        Second line.
      OUTPUT
    end
  end

  describe "with a single commit argument" do
    it "formats a single commit" do
      test_dir = "single_commit"
      prepare_repository test_dir do
        create_commit "Commit subject 1", "Commit message body.\nSecond line."
        create_commit "Commit subject 2", "Commit message body.\nSecond line."
      end

      output = run(test_dir, ["HEAD~1..HEAD"])
      expect(output).to eql(<<~OUTPUT)
        ## Commit subject 2

        Commit message body.
        Second line.
      OUTPUT
    end
  end

  describe "with multiple commits argument" do
    it "formats multiple commits" do
      test_dir = "multiple_commits"
      prepare_repository test_dir do
        create_commit "Commit subject 1", "Commit message body.\nSecond line."
        checkout_branch "my-branch"
        create_commit "Commit subject 2", "Commit message body.\nSecond line."
        create_commit "Commit subject 3", "Commit message body.\nSecond line."
      end

      output = run(test_dir, ["main...HEAD"])
      expect(output).to eql(<<~OUTPUT)
        ## Commit subject 2

        Commit message body.
        Second line.

        ## Commit subject 3

        Commit message body.
        Second line.
      OUTPUT
    end

    it "indents headings by one level" do
      test_dir = "multiple_commits"
      message_body = <<~MESSAGE
        Commit message body.

        ## Sub heading 1

        First section.

        ## Sub heading 2

        Second section.
      MESSAGE
      prepare_repository test_dir do
        create_commit "Commit subject 1", message_body
        create_commit "Commit subject 2", message_body
        create_commit "Commit subject 3", message_body
      end

      output = run(test_dir, ["HEAD~2...HEAD"])
      expect(output).to eql(<<~OUTPUT)
        ## Commit subject 2

        Commit message body.

        ### Sub heading 1

        First section.

        ### Sub heading 2

        Second section.

        ## Commit subject 3

        Commit message body.

        ### Sub heading 1

        First section.

        ### Sub heading 2

        Second section.
      OUTPUT
    end
  end

  def run(dir_name, args = [])
    capture_stdout do
      in_repository dir_name do
        CommitFormat::Cli.new(args).execute
      end
    end
  end

  def run_version
    `bin/commit-format --version`
  end
end
