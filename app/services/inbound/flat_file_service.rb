module Inbound
  class FlatFileService
    # TODO: implement flat file service for S3; rename class to reflect S3?
    def write_to_file(name:, ext: 'txt', data:)
      File.open("tmp/#{name}.#{ext}", 'w') { |f| f.puts data }
    end
  end
end
