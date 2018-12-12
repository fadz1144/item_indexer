module External
  module XPDM
    class Base < ApplicationRecord
      self.abstract_class = true
      establish_connection "external_pdm_#{Rails.env}".to_sym if Rails.configuration.settings['enable_pdm_connection']
      include External::XPDM::CreatedUpdatedStamps
      extend External::DateComparisonQueryBuilders

      def self.updates_since(datetime)
        date_gteq(datetime)
      end

      def self.no_updates_since(datetime)
        date_lteq(datetime)
      end
    end
  end
end
