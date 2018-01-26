module Reindex
  class BaseReindexJob < ApplicationJob
    def perform(until_time = DateTime.current)
      ReindexEngine.new(until_time, self).run
    end

    def lock_name
      "#{self.class.name}:#{index_type}"
    end
  end
end
