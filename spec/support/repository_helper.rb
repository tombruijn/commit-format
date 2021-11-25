# frozen_string_literal: true

module RepositoryHelper
  REPOSITORY_TEST_DIR = File.join(ROOT_DIR, "tmp/examples")

  def prepare_repository(dir_name)
    directory = directory_path(dir_name)
    FileUtils.rm_rf directory
    FileUtils.mkdir_p directory
    Dir.chdir directory do
      `git init .`
      create_commit "Initial commit", ""
      yield
    end
  end

  def in_repository(dir_name, &block)
    directory = directory_path(dir_name)
    Dir.chdir(directory, &block)
  end

  def directory_path(dir_name)
    File.join(REPOSITORY_TEST_DIR, dir_name)
  end

  def create_commit(subject, message)
    `git commit --allow-empty -m "#{subject}" -m "#{message}"`
  end
end
