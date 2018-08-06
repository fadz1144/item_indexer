module CatalogTransformer
  module Associations
    class Base
      attr_reader :name, :match_keys

      def initialize(name, source_name, transformer_name, match_keys = nil)
        @name = name
        @source_name = source_name
        @transformer_name = transformer_name
        @match_keys = build_match_keys(match_keys)
      end

      def source_name
        @source_name || :itself
      end

      def source_includes
        nested = transformer_class.source_includes.flatten

        if @source_name.present?
          nested.present? ? { @source_name => nested } : @source_name
        else
          nested.presence
        end
      end

      def target_includes
        nested = transformer_class.target_includes
        nested.empty? ? @name : { @name => nested }
      end

      def transformer_class
        @transformer_name.constantize
      end

      # if the match keys need to be enhanced to support different names on source and target, then a hash could be used
      # instead, and this could convert any arrays or strings to a hash
      def build_match_keys(match_keys)
        [match_keys].flatten.map(&:to_s) if match_keys.present?
      end
    end
  end
end
