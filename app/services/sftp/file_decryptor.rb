module Sftp
  class FileDecryptor
    include BridgeShell

    def self.decrypt(local_filename, output_filename = nil)
      output_filename ||= default_filename(local_filename)
      Rails.logger.info "Decrypting '%s' to '%s'..." % [local_filename, output_filename]
      # gpg --output 1111SKU_Site_Coupon_Reduction.txt --decrypt SKU_Site_Coupon_Reduction.txt.gpg
      Rails.logger.debug 'Decryption output follows:'
      new.shell_cmd(['gpg', '--output', output_filename, '--decrypt', local_filename])
      output_filename
    end

    ENDING = /\.gpg\z/
    def self.default_filename(local_name)
      if ENDING.match?(local_name)
        local_name.sub(ENDING, '')
      else
        'Decrypted-%s' % local_name
      end
    end
  end
end
