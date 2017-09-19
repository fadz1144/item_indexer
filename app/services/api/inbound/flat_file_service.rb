module API
  module Inbound
    class FlatFileService
      # TODO: implement flat file service for S3; rename class to reflect S3?

      BASE_PATH = 'okl'.freeze

      def write_to_file(name:, ext: 'txt', data:)
        filename = write_to_tmp(data, ext, name)

        # looks like AWS wants the file written to disk (especially if it can be large)
        enqueue_s3_write(ext, filename, name) if log_to_s3?
      end

      # TODO: put this operation on a queue
      def enqueue_s3_write(ext, file, name)
        @bucket_name ||= Rails.configuration.settings['inbound']['s3_bucket']

        begin
          s3_file_name = s3_file_name(source: BASE_PATH, name: name, ext: ext)
          upload_to_s3(bucket: @bucket_name, name: s3_file_name, file: file)
        rescue StandardError => e
          puts 'Unable to upload to S3'
          puts e.backtrace.join("\n")
        end
      end

      def write_to_tmp(data, ext, name)
        filename = "tmp/#{name}.#{ext}"
        File.open(filename, 'w') { |f| f.puts data }
        filename
      end

      private

      def log_to_s3?
        if Rails.configuration.settings.key?('inbound')
          Rails.configuration.settings['inbound'].fetch('log_to_s3', false)
        else
          false
        end
      end

      def s3_file_name(source:, name:, ext:)
        day_str = Time.now.strftime('%Y%m%d')
        "#{source}/#{day_str}/#{name}.#{ext}"
      end

      def upload_to_s3(bucket:, name:, file:)
        s3  = Aws::S3::Resource.new
        obj = s3.bucket(bucket).object(name)
        obj.upload_file(file, acl: 'private')
      end
    end
  end
end
