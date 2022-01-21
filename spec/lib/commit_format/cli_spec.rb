# frozen_string_literal: true

RSpec.describe CommitFormat::Cli do
  describe "without an argument" do
    it "formats the last commit" do
      test_dir = "last_commit"
      prepare_repository test_dir do
        create_commit "Commit subject", "Commit message body.\nSecond line."
      end

      output = run(test_dir)
      expect(output).to eql(<<~OUTPUT)
        ## Commit subject

        Commit message body.
        Second line.
      OUTPUT
    end
  end

  describe "with a single commit argument" do
    it "formats a single commit" do
      test_dir = "single_commit"
      prepare_repository test_dir do
        create_commit "Commit subject", "Commit message body.\nSecond line."
      end

      output = run(test_dir, ["HEAD~1..HEAD"])
      expect(output).to eql(<<~OUTPUT)
        ## Commit subject

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
        create_commit "Commit subject 2", "Commit message body.\nSecond line."
      end

      output = run(test_dir, ["HEAD~2...HEAD"])
      expect(output).to eql(<<~OUTPUT)
        ## Commit subject 1

        Commit message body.
        Second line.

        ## Commit subject 2

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
      end

      output = run(test_dir, ["HEAD~2...HEAD"])
      expect(output).to eql(<<~OUTPUT)
        ## Commit subject 1

        Commit message body.

        ### Sub heading 1

        First section.

        ### Sub heading 2

        Second section.

        ## Commit subject 2

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
end
