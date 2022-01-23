# frozen_string_literal: true

RSpec.describe CommitFormat::Cli do
  describe "with --version flag" do
    it "prints the version number" do
      output = run_version
      expect(output).to eql(CommitFormat::VERSION)
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
    capture_stdout do
      CommitFormat::Cli.new(["--version"]).execute
    end
  end
end
