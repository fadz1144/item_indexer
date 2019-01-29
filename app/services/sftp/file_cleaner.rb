module Sftp
  class FileCleaner
    class CouldntCleanFileError < StandardError; end
    include BridgeShell
    def self.clean_invalid_chars(filepath)
      temp_name = '%s-clean' % filepath
      command = "iconv -c -t UTF-8 < '%s' > '%s'"
      run_shell_command_without_caring_about_exit_status([command % [filepath, temp_name]])
      raise CouldntCleanFileError, 'Error cleaning the bad characters from the file.' unless File.exist?(temp_name)
      File.unlink(filepath)
      File.rename(temp_name, filepath)
      filepath
    end

    # rubocop:disable Lint/HandleExceptions - no this directive doesn't work here when put on the function level
    def self.run_shell_command_without_caring_about_exit_status(command_array)
      new.shell_cmd(command_array)
    rescue BridgeShell::NonzeroExitStatus
    end
    # rubocop:enable Lint/HandleExceptions

    private_class_method :run_shell_command_without_caring_about_exit_status
  end
end
