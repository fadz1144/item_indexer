module External
  module DateComparisonQueryBuilders
    # the Oracle DATE field includes date and time
    ORACLE_TO_DATE_FORMAT = 'YYYY-MM-DD"T"HH24:MI:SS'.freeze

    def date_gteq(datetime, field_name = :update_ts)
      tbl = quoted_table_name
      where("#{tbl}.#{field_name} >= TO_DATE(?, ?)", utc_to_eastern_without_zone(datetime), ORACLE_TO_DATE_FORMAT)
    end

    private

    def utc_to_eastern_without_zone(datetime)
      datetime.in_time_zone('Eastern Time (US & Canada)').strftime('%FT%R')
    end
  end
end
