module External
  module XPDM
    module TransformerNonActiveRecordModel
      extend ActiveSupport::Concern

      module ClassMethods
        # dummy method to satisfy CatalogTransformers::Attributes.references_from_model
        def reflect_on_all_associations
          []
        end
      end
    end
  end
end
