# frozen_string_literal: true

require "tempfile"
require "securerandom"

module OutputHelper
  def std_stream
    Tempfile.new SecureRandom.uuid
  end

  # Capture STDOUT in a variable
  #
  # Given tempfiles are rewinded and unlinked after yield, so no cleanup
  # required. You can read from the stream using `stdout.read`.
  #
  # Usage
  #
  #     out_stream = Tempfile.new
  #     capture_stdout(out_stream) { do_something }
  def capture_stdout(stdout = std_stream)
    original_stdout = $stdout.dup
    $stdout.reopen stdout

    begin
      yield
    ensure
      $stdout.reopen original_stdout
      stdout.rewind
      stdout.unlink
    end
    stdout.read
  end
end
