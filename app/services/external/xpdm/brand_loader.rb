module External
  module XPDM
    class BrandLoader
      def self.perform
        new.load
      end

      def load
        External::XPDM::Brand.in_batches(load: true) do |pdm_brands|
          results = []
          pdm_brands.each do |pdm_brand|
            next unless pdm_brand.valid?
            results << build_concept_brand(pdm_brand)
          end

          # save each batch of records within a transaction (less commits, not after atomicity here)
          CatModels::ConceptBrand.transaction { results.each(&:save!) }
        end
      end

      private

      def build_concept_brand(brand)
        CatModels::ConceptBrand
          .new(concept: concept, source_brand_id: brand.brand_cd.to_i, name: brand.brand_name,
               brand: find_or_build_brand(brand.brand_name),
               active: true, status: 'ACTIVE',
               source_created_at: brand.source_created_at, source_updated_at: brand.source_updated_at)
      end

      def concept
        @concept ||= CatModels::Concept.find(99)
      end

      def find_or_build_brand(name)
        brand_cache[name] || CatModels::Brand.new(name: name)
      end

      def brand_cache
        # reversing the order so the first Id is used when a name appears more than once
        @brand_cache ||= CatModels::Brand.order(brand_id: :desc).index_by(&:name)
      end
    end
  end
end
