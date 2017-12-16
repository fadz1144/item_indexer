module CatalogTransformer
  module Associations
    class SingularHandler
      def initialize(source, target)
        @source = source
        @target = target
      end

      def transform_association(association)
        target_record = @target.public_send(association.name) || @target.public_send("build_#{association.name}")
        transformer = association.transformer_class.new(source_record(association))
        transformer.apply_transformation(target_record)
      end

      private

      def source_record(association)
        @source.public_send(association.source_name)
      end
    end
  end
end
