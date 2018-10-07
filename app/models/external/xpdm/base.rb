module External
  module XPDM
    class Base < ApplicationRecord
      self.abstract_class = true
      establish_connection "external_pdm_#{Rails.env}".to_sym if Rails.configuration.settings['enable_pdm_connection']
      include External::XPDM::CreatedUpdatedStamps
    end
  end
end
