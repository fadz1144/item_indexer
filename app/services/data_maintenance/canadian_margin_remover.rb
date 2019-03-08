module DataMaintenance
  class CanadianMarginRemover
    def perform
      count = count_skus_to_clear
      if count.zero?
        log 'No skus contain a margin that should be cleared'
        return
      end

      log_count(count)
      elapsed_ms = Benchmark.ms { fetch_and_update_skus }
      log_elapsed_time(elapsed_ms)
    end

    private

    def fetch_and_update_skus
      batch = fetch_sku_ids

      until batch.empty?
        batch.in_groups_of(1_000, false) do |sku_ids|
          update(sku_ids)
        end

        batch = fetch_sku_ids(batch.max)
      end
    end

    def log_count(count)
      pretty_count = ActiveSupport::NumberHelper.number_to_delimited(count)
      log "Count of skus to clear: #{pretty_count}"
    end

    def log_elapsed_time(milliseconds)
      seconds = milliseconds / 1_000
      display_seconds = seconds.modulo(60).round
      display_time = ["#{display_seconds} #{'second'.pluralize(display_seconds)}"]

      display_minutes = (seconds / 60.0).floor
      display_time.unshift("#{display_minutes} #{'minute'.pluralize(display_minutes)}") if display_minutes > 0
      log "Completed in #{display_time.join(', ')}"
    end

    def fetch_sku_ids(last_sku_id = 0)
      sku_ids_relation
        .where('sku_id > ?', last_sku_id)
        .limit(10_000)
        .pluck(:sku_id)
    end

    def sku_ids_relation
      CatModels::ConceptSkuPricing
        .select(:sku_id)
        .where(concept_id: [1, 2])
        .where.not(margin_amount: nil)
        .group(:sku_id)
        .having('not (max(cost) = min(cost) and max(retail_price) = min(retail_price))')
        .having('not (max(cost) <> min(cost) and max(retail_price) <> min(retail_price))')
    end

    def count_skus_to_clear
      CatModels::ConceptSkuPricing
        .connection
        .execute("select count(*) as sku_count from (#{sku_ids_relation.to_sql}) a")
        .first
        .fetch('sku_count')
    end

    def update(sku_ids)
      CatModels::ConceptSkuPricing
        .where(sku_id: sku_ids, concept_id: 2)
        .update_all(margin_amount: nil, margin_percent: nil) # rubocop:disable Rails/SkipsModelValidations
    end

    def log(message)
      Rails.logger.info "[#{self.class.name}] #{message} "
    end
  end
end
