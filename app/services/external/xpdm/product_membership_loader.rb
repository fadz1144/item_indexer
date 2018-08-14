module External
  module XPDM
    class ProductMembershipLoader
      def base_arel
        External::XPDM::ProductMembership
      end

      def transformer_class
        nil
      end

      def transform(_engine, arel)
        ids_in_batches(arel) do |batch|
          insert_values(batch.reject { |ids| ids[1].to_i.zero? })
        end
      end

      # products have multiple skus, so the last product might be partially loaded; it is deleted at restart
      def restart_id
        restart_id = External::XPDM::ProductMembershipLocal.maximum(:pdm_object_id)
        return nil if restart_id.nil?
        External::XPDM::ProductMembershipLocal.where(pdm_object_id: restart_id).delete_all
        restart_id - 1
      end

      private

      def insert_values(batch)
        table_name = External::XPDM::ProductMembershipLocal.table_name
        values = "(#{batch.map { |a| a.join(',') }.join('), (')})"
        External::XPDM::ProductMembershipLocal.connection.execute(
          "INSERT INTO #{table_name}(pdm_object_id, item_code_name_cd) VALUES #{values}"
        )
      end

      def ids_in_batches(arel)
        arel = arel.order(:pdm_object_id, :item_code_name_cd).limit(10_000).skip_query_cache!
        batch_arel = arel

        loop do
          rows = batch_arel.pluck(:pdm_object_id, :item_code_name_cd)
          break if rows.empty?

          yield rows
          batch_arel = greater_than_last_row(arel, rows.last)
        end
      end

      def greater_than_last_row(arel, last_row)
        arel.where(arel.arel_attribute(:pdm_object_id).gt(last_row[0]),
                   arel.arel_attribute(:item_code_name_cd).gt(last_row[1]))
      end
    end
  end
end
