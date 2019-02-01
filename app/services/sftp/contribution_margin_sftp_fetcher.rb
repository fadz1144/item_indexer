module Sftp
  class ContributionMarginSftpFetcher
    attr_reader :local_directory
    REMOTE_DIR_ENTRY = :contribution_margin
    PREFIX_TO_ADD_AFTER_SUCCESS = 'PROCESSED-'.freeze

    def initialize
      @settings = YAML.load(ERB.new(File.read(Rails.root.join('config', 'sftp.yml'))).result).fetch(Rails.env)
      connect
      @local_directory = @settings['local_directory']
      @files_fetched = []
    end

    def run
      files = @sftp_client.files
      Rails.logger.info 'Directory listing: %s' % files.join(' ')
      system 'mkdir -p \'%s\'' % @local_directory
      download_files(files)
      @sftp_client.close_connection
      @files_fetched
    end

    def connect
      @sftp_client = MftSftpClient.new(@settings, REMOTE_DIR_ENTRY)
    end

    # Near future: Probably Delete. When directory listings get big, it takes a very, very long time to get the listing.
    # hashtag: lessons learned dealing with Kibo
    def remove_from_server(files)
      files.each do |filename|
        Rails.logger.info 'Deleting: %s' % filename
        @sftp_client.delete(nil, filename)
      end
    end

    private

    def download_files(files)
      files.each do |file|
        next if file.start_with? PREFIX_TO_ADD_AFTER_SUCCESS
        mtime = @sftp_client.modified_time(nil, file)
        Rails.logger.info 'Downloading %s (mtime %s)...' % [file, mtime]
        @sftp_client.download(file: file, to: @local_directory)
        @files_fetched << file
      end
    end

    attr_reader :settings
  end
end
