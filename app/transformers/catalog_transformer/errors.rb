module CatalogTransformer
  module Errors
    class TransformError < StandardError
    end

    class CouldNotReadAttribute < TransformError
      def initialize(transformer_name, model_name, attribute_name, message)
        super "[#{transformer_name}] Transformer failed while trying to read attribute '#{attribute_name}' from " \
          "#{model_name}.\n#{message}"
      end

      def backtrace
        cause&.backtrace || super
      end
    end

    class AssociationNotDefined < TransformError
      def initialize(parent_class, name)
        suggestion = did_you_mean?(parent_class, name)
        error = "Class #{parent_class.name} does not include association #{name}"
        super error + suggestion
      end

      def did_you_mean?(parent_class, name)
        checker = DidYouMean::SpellChecker.new(dictionary: parent_class.reflections.values.map(&:name))
        suggestion = checker.correct(name)
        suggestion.empty? ? '' : "\n\tDid you mean?\t#{suggestion.join("\t\t")}"
      end
    end
  end
end
