module PDM
  class SystemStatusMapper
    ROLLUP_SORT = [CatModels::Constants::SystemStatus::ACTIVE,
                   CatModels::Constants::SystemStatus::INACTIVE,
                   CatModels::Constants::SystemStatus::DROPPED,
                   CatModels::Constants::SystemStatus::DISCONTINUED,
                   CatModels::Constants::SystemStatus::TO_BE_PURGED,
                   CatModels::Constants::SystemStatus::UNKNOWN].freeze

    # both U and any non-mapped values are set to UNKNOWN
    CODE_TO_VALUE = {
      'A' => CatModels::Constants::SystemStatus::ACTIVE,
      'D' => CatModels::Constants::SystemStatus::DISCONTINUED,
      'I' => CatModels::Constants::SystemStatus::INACTIVE,
      'N' => CatModels::Constants::SystemStatus::DROPPED,
      'P' => CatModels::Constants::SystemStatus::TO_BE_PURGED
    }.freeze

    def self.value(status_cd)
      CODE_TO_VALUE.fetch(status_cd, CatModels::Constants::SystemStatus::UNKNOWN)
    end
  end
end
