module External
  module Type
    class XPDMBooleanIndicator < ActiveModel::Type::Boolean
      TRUE_VALUES = %w[y yes].to_set

      def deserialize(value)
        TRUE_VALUES.include? value.downcase
      rescue
        false
      end
    end
  end
end
