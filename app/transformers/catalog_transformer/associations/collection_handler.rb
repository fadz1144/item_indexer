module CatalogTransformer
  module Associations
    class CollectionHandler
      def initialize(source, target, partial)
        @source = source
        @target = target
        @partial = partial
      end

      def transform_association(association)
        target_records = indexed_target_records(association)
        transformers = indexed_transformers(association)

        update_matches(target_records, transformers, nil)
        delete_missing(target_records, transformers) unless @partial
        add_new(target_records, transformers, association.name, nil)
      end

      private

      def indexed_target_records(association)
        @target.public_send(association.name)
               .index_by do |r|
          association.match_keys.map { |key| r.public_send(key) }
        end
      end

      def indexed_transformers(association)
        source_records(association)
          .map { |source| association.transformer_class.new(source) }
          .index_by do |t|
          association.match_keys.map { |key| t.attribute_values[key.to_s] }
        end
      end

      def source_records(association)
        [@source.public_send(association.source_name)].flatten
      end

      def update_matches(target_records, transformers, parent_key)
        (target_records.keys & transformers.keys).each do |match_key|
          transformers[match_key].apply_transformation(target_records[match_key], parent_key)
        end
      end

      def delete_missing(target_records, transformers)
        (target_records.keys - transformers.keys).each do |miss_key|
          target_records[miss_key].mark_for_destruction
        end
      end

      def add_new(target_records, transformers, association_name, parent_key)
        (transformers.keys - target_records.keys).each do |new_key|
          transformers[new_key].apply_transformation(@target.public_send(association_name).build, parent_key)
        end
      end
    end
  end
end
