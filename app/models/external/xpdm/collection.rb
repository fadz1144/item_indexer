module External
  module XPDM
    class Collection < External::XPDM::Item
      # this is not a default scope, because it's not needed when in_batches fetches by id
      # for all other queries, it does need to be included
      scope :web_collection, -> { where(pdm_object_type: %w[WebCollection WEBCOLLECTION]) }
    end
  end
end
