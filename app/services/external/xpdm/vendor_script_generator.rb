module External
  module XPDM
    # generates insert scripts directly from XPDM tables; deprecated in favor of VendorLoader and generating scripts
    # from the catalog tables themselves
    class VendorScriptGenerator < External::InsertScriptGenerator
      private

      def target_name
        :concept_vendors
      end

      def source_arel
        External::XPDM::Vendor
      end

      def values(item)
        { concept_id: 99,
          source_vendor_id: item.vendor_num,
          name: item.vendor_name }.merge(timestamps(item))
      end
    end
  end
end
