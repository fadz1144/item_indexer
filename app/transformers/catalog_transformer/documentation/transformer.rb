module CatalogTransformer
  module Documentation
    # = Inspector
    #
    # The Inspector class documents transformers. It is NOT used by the transformation service; it is reference only.
    #
    ## Example
    #    pp CatalogTransformer::Documentation::Transformer.new.document(Transform::Transformers::OKL::ConceptProduct)
    class Transformer
      def document(transformer)
        @transformer = transformer
        { transformer: transformer.name,
          attributes:
            @transformer.attributes.map { |a| CatalogTransformer::Documentation::Attribute.new(@transformer, a).to_h } }
      end

      private

      def document_attribute(attribute)
        source_model = attribute_source_model(attribute.source_record_name)

        { source_table: source_model.table_name,
          source_column: attribute_source_column(source_model, attribute.source_name),
          target: attribute.name }
      end

      def attribute_source_model(name)
        if name.to_s == 'itself'
          @transformer.source_class
        else
          @transformer.source_class.reflect_on_association(name).active_record
        end
      end

      # decorated methods are starred
      def attribute_source_column(source_model, source_name)
        if source_model.column_names.include? source_name
          source_name
        else
          "#{source_name}*"
        end
      end
    end
  end
end
