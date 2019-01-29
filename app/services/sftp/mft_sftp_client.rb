require 'fun_sftp'
module Sftp
  class MftSftpClient
    # Cribbed initially from my previous work in Elysium: KiboSftpClient
    include FunSftp

    def initialize(sftp_settings, directory_entry)
      @config = sftp_settings
      @config['default_directory'] = @config.dig('directories', directory_entry.to_s)
      Rails.logger.debug("Connecting to '#{@config.inspect}'...")
      @connection = SFTPClient.new(@config['host'], @config['username'], '',
                                   keys: [@config['ssh_private_key']], host_key: 'ssh-rsa')
      configure_sftp
      Rails.logger.info @config.inspect
    end

    def close_connection
      @connection&.client&.session&.close
    end

    def upload_files(directory, files_list)
      remote_directory = directory
      files_list.each do |file|
        remote_name = File.basename(file)
        @connection.upload!(file, "#{remote_directory}/#{remote_name}")
      end
    end

    def files(directory: nil, pattern: '**/*')
      dir = if directory.nil?
              default_directory
            else
              "#{default_directory}/#{directory}"
            end
      @connection.glob(dir, pattern)
    end

    def download(file:, to:)
      target_filename = File.basename(file)
      Rails.logger.info "DOWNLOADING --->      #{to}/#{target_filename}"
      @connection.download!("#{default_directory}/#{file}", "#{to}/#{target_filename}")
    end

    def rename(directory_location, name, new_name)
      directory_location ||= default_directory
      @connection.rename("#{directory_location}/#{name}", "#{directory_location}/#{new_name}")
    end

    def modified_time(directory_location, name)
      @connection.mtime("#{directory_location}/#{name}")
    end

    def dir_exists?(directory_location, path)
      # Rails.logger.info "Sending Has Directory #{directory_location}/#{path} ..."
      @connection.has_directory?("#{directory_location}/#{path}")
    end

    def mkdir!(directory_location, path)
      # Rails.logger.info "Sending MKDIR #{directory_location}/#{path} ..."
      @connection.mkdir!("#{directory_location}/#{path}")
    end

    private

    def configure_sftp
      FunSftp.configure do |config|
        config.log = false # unless Rails.env.development?
      end
    end

    def default_directory
      @config['default_directory']
    end
  end
end
