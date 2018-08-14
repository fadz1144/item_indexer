module External
  class InsertScriptGenerator
    def initialize(arel, folder_name = nil, logger = nil, prefix = nil)
      @arel = arel
      @path = folder_name.present? ? Rails.root.join('tmp', folder_name) : Rails.root.join('tmp')
      @logger = logger || Rails.logger
      @now = Time.zone.now
      @prefix = prefix
    end

    def generate_inserts
      init_file
      count = 0
      @arel.in_batches(load: true) do |items|
        inserts = filter(items).map { |b| insert_item(b) }
        append_to_file(inserts)
        count += inserts.size
      end

      @logger.info "Generated #{count.to_s(:delimited)} inserts for #{target_name}"
    end

    private

    def table
      @table ||= Arel::Table.new(target_name)
    end

    # override target name to insert to different table
    def target_name
      @arel.table_name
    end

    def filter(items)
      items
    end

    def file_name
      File.join(@path, "#{@prefix}insert_#{target_name}.sql")
    end

    def insert_item(item)
      m = Arel::InsertManager.new
      m.into(table)
      m.insert(column_value_pairs(table, item))
      m.to_sql + ';'
    end

    def column_value_pairs(table, item)
      values(item).map { |column_name, value| [table[column_name], value] }
    end

    # override values to build custom insert script
    def values(item)
      item.attributes
    end

    def timestamps(item)
      { source_created_at: item.source_created_at,
        source_updated_at: item.source_updated_at,
        created_at: @now,
        updated_at: @now }
    end

    def init_file
      File.open(file_name, 'w') do |f|
        f.puts "-- generated at #{Time.zone.now}"
      end
    end

    def append_to_file(inserts)
      File.open(file_name, 'a') do |f|
        inserts.each { |b| f.puts b }
      end
    end
  end
end
