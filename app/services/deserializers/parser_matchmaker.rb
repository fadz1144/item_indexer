require 'csv'
module Deserializers
  class ParserMatchmaker
    PARSERS = [ContributionMarginFileParser].freeze

    def self.init_parser(filepath)
      keys = keys(filepath)
      parser = PARSERS.detect do |parser_class|
        parser_class.wants?(keys)
      end
      if parser.nil?
        Rails.logger.warn('ALERT: Nobody wanted the file %s' % filepath)
        return nil
      end
      parser.new(filepath, col_sep: settings['col_sep'])
    end

    # Grab column headers for analysis
    def self.keys(filepath)
      keys = nil
      CSV.foreach(filepath, headers: true, col_sep: settings['col_sep']) do |row|
        keys = row.to_hash.keys.sort
        break
      end
      keys
    end

    def self.settings
      @settings ||= YAML.load(ERB.new(File.read(Rails.root.join('config', 'csv.yml'))).result).fetch(Rails.env)
    end
  end
end
