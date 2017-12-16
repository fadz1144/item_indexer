module CatalogTransformer
  module SourceClassAccessors
    extend ActiveSupport::Concern

    # Source Class Accessors enable transformers to specify the name of the source model.
    #
    # == Example
    #
    # The source name for the ConceptSku transformer is the SkuRevision model:
    #   source_name 'Inbound::OKL::SkuRevision'
    module ClassMethods
      def source_name(model_name)
        @source_name = model_name
      end

      def source_class
        @source_name.constantize
      end
    end
  end
end
