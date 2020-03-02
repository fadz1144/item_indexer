module Transform
  module Transformers
    module XPDM
      module SharedConceptImages
        extend ActiveSupport::Concern

        def primary
          alt_index.zero?
        end

        def concept_id
          99
        end

        def hosting_service
          'Scene7'.freeze
        end

        def resource_folder
          'BedBathandBeyond'.freeze
        end

        def sort_order
          (alt_index + 1) * 1_000
        end
      end
    end
  end
end
