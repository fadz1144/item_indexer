module External
  module JDA
    class Base < ApplicationRecord
      self.abstract_class = true
      establish_connection "external_jda_#{Rails.env}".to_sym
    end
  end
end
