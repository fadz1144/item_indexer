module Sftp
  class FileCleaner
    class CouldntCleanFileError < StandardError; end
    include BridgeShell

    # Note: THIS ALLOWS ONLY A SMALL SET OF CHARACTERS! BEFORE YOU USE THIS, ENSURE THIS IS OK.
    # For one thing, very little punctuation or symbols will survive.
    def self.clean_invalid_chars(filepath)
      temp_name = '%s-clean' % filepath
      command = "tr -C 'A-Za-z0-9_\\-.|, \n' '?' < '%s' > '%s'"
      new.shell_cmd([command % [filepath, temp_name]])
      raise CouldntCleanFileError, 'Error cleaning the bad characters from the file.' unless File.exist?(temp_name)
      File.unlink(filepath)
      File.rename(temp_name, filepath)
      filepath
    end
  end
end
