module External
  module XPDM
    class BrandLoader
      def initialize
        transformer_class.init_class_variables
      end

      def base_arel
        External::XPDM::Brand
      end

      def transformer_class
        Transform::Transformers::XPDM::ConceptBrand
      end

      def transform(engine, arel)
        arel.in_batches do |brands|
          engine.transform_items(brands)
        end
      end
    end
  end
end
