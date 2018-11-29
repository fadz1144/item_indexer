module External
  module XPDM
    module CreatedUpdatedStamps
      def source_created_at
        create_ts.presence || default_timestamp
      end

      def source_updated_at
        update_ts.presence || default_timestamp
      end

      def source_created_by
        0
      end

      def source_updated_by
        0
      end

      def created_updated_stamp_attributes
        { source_created_at: source_created_at,
          source_updated_at: source_updated_at,
          source_created_by: source_created_by,
          source_updated_by: source_updated_by }
      end

      private

      def default_timestamp
        load_ts.presence || Time.zone.now
      end
    end
  end
end
