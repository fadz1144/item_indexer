module CatalogTransformer
  module Documentation
    # = Attribute
    #
    # This class documents the source and target for attributes. If the source of an attribute is an association or a
    # decorator method, then the name of that source is starred:
    #
    #   { :source_table => "inbound_okl_product_revisions", :source_column => "active*", :target => "active" }
    class Attribute
      def initialize(transformer, attribute)
        @transformer = transformer
        @attribute = attribute
      end

      def to_h
        { source_table: source_table, source_column: source_column, target: target }
      end

      def source_table
        source_model.table_name
      end

      def source_column
        if source_model.column_names.include? @attribute.source_name
          @attribute.source_name
        else
          "#{@attribute.source_name}*"
        end
      end

      def target
        @attribute.name
      end

      private

      def source_model
        @source_model ||= if @attribute.source_record_name.to_s == 'itself'
                            @transformer.source_class
                          else
                            @transformer.source_class
                                        .reflect_on_association(@attribute.source_record_name)
                                        .class_name
                                        .constantize
                          end
      end
    end
  end
end
