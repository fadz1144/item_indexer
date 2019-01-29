module Deserializers
  class ContributionMarginFileParser
    FIELDS_I_NEED = %w[cm_l4w cm_rate_l4w coupon_l4w freight_in_l4w freight_out_l4w md_reimb_l4w rtv_da_l4w rtv_mos_l4w
                       ship_fee_coll_l4w shrink_l4w site_id skuid sls_cost_l4w sls_ret_l4w
                       sls_unit_l4w vend_supp_l4w].to_set.freeze
    INBOUND_RECORD_CLASS = 'Inbound::DW::ContributionMarginFeed'.freeze
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
      end
      complete_batch
    rescue => e
      erroneous_batch(e)
    end

    private

    def make_record(row)
      inbound_record_class = INBOUND_RECORD_CLASS.constantize
      fields = row.to_h.tap { |r| r.transform_keys!(&:downcase) }
      data = fields.slice(*FIELDS_I_NEED)
      data['sku_id'] = data.delete 'skuid'
      record = inbound_record_class.new(data)
      record.inbound_batch = @batch
      # Rails.logger.debug record.inspect
      record.save!
    end

    def init_batch
      inbound_record_class = INBOUND_RECORD_CLASS.constantize
      inbound_detail = { status: Inbound::Batch::STATUS_IN_PROGRESS,
                         file_name: File.basename(@filename) }
      @batch = Inbound::Batch.new(inbound_record_class.inbound_batch_fields.merge(inbound_detail)).tap(&:save!)
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
  end
end
