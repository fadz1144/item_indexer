module CatalogUpdates
  # = Update Service
  #
  # The UpdateService class takes an update specification, then runs the updates 1,000 rows at a time. The table's
  # indexes are dropped prior to the updates then restored afterwards.
  #
  # The update specification needs to provide the following:
  # - arel: an arel that returns the rows to be updated
  # - update_statement: the statement that follows keyword SET (but does not include set)
  class UpdateService
    def initialize(update)
      @update = update
    end

    def execute
      Rails.logger.tagged(@update.class.name) do
        process_update
      end
    end

    private

    def process_update
      start
      init_count
      CatalogUpdates::IndexSuppressor.new(model).without_indexes do
        prep_for_updates
        updates
      end
    rescue => e
      Rails.logger.error e.message
    ensure
      stop
    end

    def start
      @start_timestamp = Time.zone.now
      Rails.logger.info "Begin #{self.class.name}"
    end

    def init_count
      @count = @update.arel.count
      Rails.logger.info "Records to update: #{ActiveSupport::NumberHelper.number_to_delimited(@count)}"
    end

    def prep_for_updates
      Rails.logger.info "Starting updates for #{model}"
      @start_updates_timestamp = Time.zone.now
      vacuum
    end

    def updates
      check_point_start = @start_updates_timestamp
      @update.arel.in_batches(of: 10_000).each_with_index do |batch, index|
        update_batch(batch)

        if index.modulo(10) == 9 # rubocop:disable Style/Next
          log_pace(index, check_point_start)
          check_point_start = Time.zone.now
          vacuum
        end
      end
    end

    def update_batch(batch)
      batch.where_values_hash[model.primary_key].in_groups_of(1_000) do |ids|
        if @update.respond_to? :execute_update
          @update.execute_update(ids)
        else
          execute_update(ids)
        end
      end
    end

    def execute_update(ids)
      model.where(model.primary_key => ids)
           .update_all(@update.update_statement) # rubocop:disable Rails/SkipsModelValidations
    end

    def log_pace(index, start)
      Rails.logger.info "100k updates in #{(Time.zone.now - start).round(1)} seconds;" \
                        " estimated minutes remaining: #{estimated_time_remaining(index * 10_000).round(1)}"
    end

    def estimated_time_remaining(completed)
      updates_per_second = completed / (Time.zone.now - @start_updates_timestamp)
      remaining = @count - completed
      (remaining / updates_per_second) / 60
    end

    def vacuum
      @update.arel.connection.execute("vacuum #{@update.arel.table_name}")
    end

    def stop
      duration = Time.zone.now - @start_timestamp
      Rails.logger.info "Completed #{self.class.name} in #{(duration / 60).round(1)} minutes"
    end

    def model
      @update.arel.model
    end
  end
end
