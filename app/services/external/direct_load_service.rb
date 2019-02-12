module External
  # = Direct Load Service
  #
  # The Direct Load Service provides the following entry points for a loader:
  # - full: loads all data
  # - partial: loads data for criteria passed in as arel (the arel is merged to the base arel)
  # - individual: loads data by list of primary keys
  # - incremental: loads using scope updates_since; defaults to using the last run as the timestamp
  #
  # The loader class must implement the following methods:
  # - base_arel: the arel to load the full set of data, is used as starting point for other methods
  # - transformer_class: for example, Transform::Transformers::XPDM::Product
  # - transform(engine, arel): load and transform the specified data
  class DirectLoadService
    attr_reader :batch

    def initialize(loader)
      @loader = loader
    end

    def full
      max_existing_id = restart_id
      if max_existing_id.present?
        arel = restart_from_max_id(max_existing_id)
        process(arel, direct_batch(:full, "Restart from #{max_existing_id}"))
      else
        process(@loader.base_arel, direct_batch(:full))
      end
    end

    def partial(arel, check_restart = false)
      partial_arel = @loader.base_arel.merge(arel)
      criteria = arel.to_sql

      if check_restart
        max_existing_id = restart_id
        if max_existing_id.present?
          partial_arel.merge!(restart_from_max_id(max_existing_id))
          criteria += ' (Restart from #{max_existing_id)'
        end
      end

      process(partial_arel, direct_batch(:partial, criteria))
    end

    def individual(ids)
      raise 'Too many ids (limit is 1,000); use partial' if ids.size > 1_000
      process(@loader.base_arel.where(@loader.base_arel.primary_key => ids), direct_batch(:individual, ids))
    end

    def incremental(timestamp = nil)
      timestamp ||= most_recent_run_of_incremental - look_back_window
      process(@loader.base_arel.updates_since(timestamp), direct_batch(:incremental, timestamp))
    end

    private

    def restart_from_max_id(max_existing_id)
      @loader.base_arel.where(@loader.base_arel.arel_attribute(@loader.base_arel.primary_key).gt(max_existing_id))
    end

    def direct_batch(criteria_type, criteria = nil)
      Direct::Batch.new(class_name: @loader.class.name, criteria_type: criteria_type, criteria: criteria)
    end

    # loaders can optionally implement method restart_id to support restarting full loads
    def restart_id
      @loader.restart_id if @loader.respond_to?(:restart_id)
    end

    # loaders can optionally implement method look_back_window to override the default of four hours
    def look_back_window
      @loader.respond_to?(:look_back_window) ? @loader.look_back_window : 4.hours
    end

    def most_recent_run_of_incremental
      Direct::Batch.most_recent.incremental.complete
                   .where(class_name: @loader.class.name)
                   .first&.start_datetime ||
        raise("No previous incremental run found for class #{@loader.class.name}. Run full to load all data.")
    end

    # TODO: need a good way to skip counts for arel's that don't play well with it
    def process(arel, direct_batch)
      direct_batch.count = arel.count unless @loader.class.name == 'External::XPDM::MissingImagesLoader'
      @batch = External::BatchLoader.execute_in_batch(direct_batch, @loader.transformer_class) do |engine|
        @loader.transform(engine, arel)
      end
    end
  end
end
