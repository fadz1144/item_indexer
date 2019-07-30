module Deserializers
  class DwSalesMetricsFileParser
    # Current filename of the file this parses is: " OKL_SALES.APP..."
    attr_writer :mod_time

    FIELDS_I_NEED = %w[sku_id site_id total_sales_units_l1w total_sales_units_l8w
                       total_sales_units_l52w].to_set.freeze
    INBOUND_RECORD_CLASS = 'Inbound::DW::DwSalesMetricsFeed'.freeze

    def initialize(filename, col_sep:)
      @filename = filename
      @col_sep = col_sep
    end

    def self.wants?(keys)
      FIELDS_I_NEED.subset?(keys.map(&:downcase).to_set)
    end

    def parse
      Rails.logger.info "Parsing file '%s' with parser %s using separator '%s'" % [@filename, self.class.name, @col_sep]
      init_batch
      CSV.foreach(@filename, headers: true, col_sep: @col_sep, liberal_parsing: true) do |row|
        make_record(row)
        break if ENV['MFT_TEST_ONLY_MAKE_ONE_RECORD'] == 'true'
      end
      complete_batch
    rescue => e
      erroneous_batch(e)
    end

    private

    def make_record(row)
      inbound_record_class = INBOUND_RECORD_CLASS.constantize
      fields = row.to_h.tap { |r| r.transform_keys! { |k| k.to_s.downcase } }
      data = fields.slice(*FIELDS_I_NEED)
      record = inbound_record_class.new(data)
      record.file_mod_time = mod_time
      record.inbound_batch = @batch
      record.save!
    end

    def init_batch
      inbound_record_class = INBOUND_RECORD_CLASS.constantize
      inbound_detail = { status: Inbound::Batch::STATUS_IN_PROGRESS,
                         file_name: File.basename(@filename) }
      @batch = Inbound::Batch.new(inbound_record_class.inbound_batch_fields.merge(inbound_detail)).tap(&:save!)
      Rails.logger.info "Created Inbound Batch #{@batch.inbound_batch_id}"
    end

    def complete_batch
      @batch.status = @batch.class::STATUS_COMPLETE
      @batch.stop_datetime = Time.zone.now
      @batch.save!
    end

    def erroneous_batch(error)
      # First label the batch correctly
      Rails.logger.error("%s: %s\n%s" % [error.class, error.message, error.backtrace])

      @batch.mark_error("%s: %s\n%s" % [error.class, error.message, error.backtrace])
      @batch.save
      # Now this should get caught higher up in the stack so that the source file won't get marked as processed.
      # It'll also raise to Honeybadger there.
      raise(error)
    end

    def mod_time
      @mod_time || Time.zone.now
    end
  end
end
