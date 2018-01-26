module Indexer
  class ReindexJobFactory
    def self.job_for_type(type)
      "Reindex::#{type.titlecase}ReindexJob".constantize
    end
  end
end
