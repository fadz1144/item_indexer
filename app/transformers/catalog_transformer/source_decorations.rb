module CatalogTransformer
  module SourceDecorations
    extend ActiveSupport::Concern

    # There are two ways to decorate the source data. If the decorator is a module, then the module can be named via the
    # decorator_name method.
    #
    #   decorator_name 'Transform::Transformers::OKL::SomeDecorator'
    #
    # If the logic does not need to be shared it can be included in the transformer by declaring a Decorations module
    # within the transformer class itself.
    #
    # It is possible to use both a named decorator and an inline decorator.
    module ClassMethods
      def decorator_name(decorator_name)
        @decorator_name = decorator_name
      end

      def decorator
        @decorator_name.constantize
      end

      def decorator?
        @decorator_name.present?
      end

      def decorations?
        const_defined?(:Decorations, false)
      end

      def decorations
        const_get(:Decorations)
      end
    end
  end
end
