class DataWarehouseImportOrchestrator
  def initialize
    Rails.logger = Logger.new(STDOUT)
    @fetcher = Sftp::DataWarehouseSftpFetcher.new
    @files = []
    @file_tracker = {} # I hold a hash of Full Decrypted Filepath => Remote encrypted filename
    @to_delete = []
  end

  def orchestrate
    encrypted_files = @fetcher.run
    dir = @fetcher.local_directory
    encrypted_files.each { |file| decrypt_and_clean(file, dir) }
    @files.present? ? process_files : happy_no_op_message
  end

  private

  def happy_no_op_message
    Rails.logger.info 'No files found :)'
  end

  def decrypt_and_clean(file, dir)
    decrypted_filename = Sftp::FileDecryptor.decrypt(File.join(dir, file))
    Sftp::FileCleaner.clean_invalid_chars(decrypted_filename)
    @files << decrypted_filename
    @file_tracker[decrypted_filename] = file
  rescue => e
    Rails.logger.info e.inspect
    Rails.logger.error 'Unable to decrypt %s - error: %s' % [file, e.message + e.backtrace]
  end

  def process_files
    Rails.logger.debug "Files present after decryption: #{@files.join(', ')}"
    @files.each do |file|
      process_with_error_handling(file)
    end
    remove_processed_files_from_server
  end

  def process_with_error_handling(file)
    mod_time = @fetcher.mod_time_for_file(@file_tracker[file])
    parser = Deserializers::ParserMatchmaker.init_parser(file)
    raise 'No parser could be found to process %s' % file unless parser
    parser.tap { |p| p.mod_time = mod_time }.parse
    @to_delete << @file_tracker[file] # Contains the remote filename
  rescue => e
    Honeybadger.notify(e)
  end

  def remove_processed_files_from_server
    return if @to_delete.empty?
    @fetcher.connect
    @fetcher.remove_from_server(@to_delete)
  end
end
