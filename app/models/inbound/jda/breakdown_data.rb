module Inbound
  module JDA
    def self.table_name_prefix
      'inbound_jda_'
    end
    class BreakdownData < ApplicationRecord
      # AUSTOR_TO_CONCEPT = {
      #   651 => 1,
      #   3651 => 1,
      #   2291 => 2,
      #   -65_535 => 3 # allows easy testing against OKL skus
      # }.freeze
      # def concept_id
      #   virtual_store = self['AUSTOR']
      #   AUSTOR_TO_CONCEPT[virtual_store] || (raise 'Unrecognized store number in JDA pricing: %d' % virtual_store)
      # end
      #
      # def compound_source_key
      #   '%d:%d' % [concept_id, self['AUSKU']]
      # end

      def sku_id
        self['AUSKU']
      end
    end
  end
end
