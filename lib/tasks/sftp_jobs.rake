namespace :sftp do
  desc 'Get contribution margin data from SFTP source and copy to inbound tables'
  task 'get_contribution_margin_from_sftp' => :environment do
    Rails.logger = Logger.new(STDOUT)
    fetcher = Sftp::ContributionMarginSftpFetcher.new
    encrypted_files = fetcher.run
    dir = fetcher.local_directory
    files = []
    file_tracker = {} # I hold a hash of Full Decrypted Filepath => Remote encrypted filename
    to_delete = []
    encrypted_files.each do |file|
      begin
        decrypted_filename = Sftp::FileDecryptor.decrypt(File.join(dir, file))
        Sftp::FileCleaner.clean_invalid_chars(decrypted_filename)
        files << decrypted_filename
        file_tracker[decrypted_filename] = file
      rescue => e
        puts e.inspect
        Rails.logger.error 'Unable to decrypt %s - error: %s' % [file, e.message + e.message.backtrace]
      end
    end
    # TODO: Here is where i will return if there are no files, once this is turned into a method on a real class
    Rails.logger.debug "Files present after decryption: #{files.join(', ')}"
    files.each do |file|
      begin
        Deserializers::ParserMatchmaker.init_parser(file)&.parse
      rescue => e
        Honeybadger.notify(e)
      else
        # We get here if there was NOT an error handling the file.
        to_delete << file_tracker[file] # Contains the remote filename
      end
    end
    unless to_delete.empty?
      fetcher.connect
      fetcher.remove_from_server(to_delete)
    end
    # Rails.logger.info $LOAD_PATH.join("\n")
    # Rails.logger.info "xxxx %s" % Rails.root + File.join(Rails.root, 'app/models')
  end
end
