module External
  module XPDM
    # generates insert scripts directly from XPDM tables; deprecated in favor of BrandLoader and generating scripts
    # from the catalog tables themselves
    class BrandScriptGenerator < External::InsertScriptGenerator
      private

      def target_name
        :concept_brands
      end

      def source_arel
        External::XPDM::Brand
      end

      def filter(brands)
        brands.select(&:valid?)
      end

      def values(item)
        { concept_id: 99,
          source_brand_id: item.brand_cd.to_i,
          name: item.brand_name,
          active: true,
          status: 'ACTIVE' }.merge(timestamps(item))
      end
    end
  end
end
