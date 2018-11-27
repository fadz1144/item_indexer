module External
  module XPDM
    class ConceptProduct < External::XPDM::ConceptItem
      include External::XPDM::PDPUrl

      def self.parent_associations
        %w[web_info_sites]
      end

      alias_attribute :product, :parent
    end
  end
end
