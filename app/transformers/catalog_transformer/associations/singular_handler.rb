module CatalogTransformer
  module Associations
    class SingularHandler
      def initialize(source, target)
        @source = source
        @target = target
      end

      def transform_association(association)
        target_record = target_record(association)
        transformer = association.transformer_class.new(source_record(association))
        transformer.apply_transformation(target_record)
      end

      private

      def target_record(association)
        @target.public_send(association.name) || # existing association
          find_match(association) || # find existing based on the match keys
          @target.public_send("build_#{association.name}") # build a new instance
      end

      def source_record(association)
        @source.public_send(association.source_name)
      end

      # example: the concept brand transformer includes a belongs_to brand association; on a new concept brand, this
      # will try to find a matching brand using the match key of name
      def find_match(association)
        return nil if association.match_keys.nil?

        criteria = match_criteria(association)
        return nil if criteria.values.all?(&:blank?)

        # apply criteria to target class to look for existing match
        association.transformer_class.target_class.where(match_criteria(association)).first.tap do |match|
          @target.public_send("#{association.name}=", match) if match.present?
        end
      end

      # read match keys from source record
      def match_criteria(association)
        association.match_keys.each_with_object({}) do |key, memo|
          memo[key] = source_record(association).public_send(key)
        end
      end
    end
  end
end
