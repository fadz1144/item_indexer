module External
  module DateComparisonQueryBuilders
    # the Oracle DATE field includes date and time
    ORACLE_TO_DATE_FORMAT = 'YYYY-MM-DD"T"HH24:MI:SS'.freeze

    def date_gteq(datetime, field_name = nil)
      where_clause(datetime, field_name, '>=')
    end

    def date_lteq(datetime, field_name = nil)
      where_clause(datetime, field_name, '<=')
    end

    private

    def where_clause(datetime, field_name, comparator)
      where("#{field_name_clause(field_name)} #{comparator} TO_DATE(?, ?)",
            utc_to_eastern_without_zone(datetime), ORACLE_TO_DATE_FORMAT)
    end

    def field_name_clause(field_name)
      if field_name.present?
        "#{quoted_table_name}.#{field_name}"
      else
        "coalesce(#{quoted_table_name}.update_ts, #{quoted_table_name}.create_ts)"
      end
    end

    def utc_to_eastern_without_zone(datetime)
      datetime.in_time_zone('Eastern Time (US & Canada)').strftime('%FT%R')
    end
  end
end
