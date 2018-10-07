module External
  module ECOM
    class Base < ApplicationRecord
      self.abstract_class = true
      establish_connection "external_ecom_#{Rails.env}".to_sym if Rails.configuration.settings['enable_pdm_connection']
    end
  end
end
