module CatalogUpdates
  class IndexSuppressor
    def initialize(model)
      @model = model
      @indexes = indexes
    end

    def without_indexes
      with_tag { delete_indexes }
      yield
    ensure
      with_tag { create_indexes }
    end

    private

    def indexes
      @model.connection
            .select_all("select indexname, indexdef FROM pg_indexes where tablename = '#{@model.table_name}'")
            .rows
            .reject { |row| row.first.ends_with? 'pkey' }
            .each_with_object({}) do |row, memo|
        memo[row.first] = row.second
      end
    end

    def delete_indexes
      @deleted_indexes = @indexes.map do |name, definition|
        execute("drop index #{name}")
        definition
      end
    end

    def create_indexes
      @deleted_indexes.each { |statement| execute(statement) }
    end

    def execute(statement)
      Rails.logger.info statement
      @model.connection.execute(statement)
    end

    def with_tag
      Rails.logger.tagged(self.class.name) { yield }
    end
  end
end
