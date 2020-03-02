module External
  module XPDM
    class ConceptCollection < External::XPDM::ConceptItem
      include External::XPDM::PDPUrl

      def self.parent_associations
        %w[web_info_sites]
      end

      alias_attribute :collection, :parent

      def concept_collection_images
        External::XPDM::Image.from_object(collection)
      end
    end
  end
end
