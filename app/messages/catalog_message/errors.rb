module CatalogMessage
  module Errors
    class MessageError < StandardError
    end

    class AssociationNotDefined < MessageError
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
