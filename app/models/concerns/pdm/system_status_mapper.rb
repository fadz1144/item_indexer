module PDM
  class SystemStatusMapper
    ROLLUP_SORT = [CatModels::Constants::SystemStatus::ACTIVE,
                   CatModels::Constants::SystemStatus::INACTIVE,
                   CatModels::Constants::SystemStatus::DROPPED,
                   CatModels::Constants::SystemStatus::DISCONTINUED,
                   CatModels::Constants::SystemStatus::TO_BE_PURGED,
                   CatModels::Constants::SystemStatus::UNKNOWN].freeze

    def self.value(status_cd)
      CatModels::Constants::WebStatus.value(status_cd)
    end
  end
end
