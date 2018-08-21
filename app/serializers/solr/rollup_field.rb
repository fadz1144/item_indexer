module SOLR
  class RollupField
    attr_reader :field_name, :access_field, :group_action, :format

    VALID_ACCESS_TYPES = %i[pricing service concept_skus_uniq decorated].freeze
    VALID_GROUP_ACTIONS = [:min, :max, :avg, nil].freeze
    VALID_FORMATS = [:currency, :currency_cents, nil].freeze

    # Defines how we roll up the field
    # field_name: the name of the field we want written to SOLR
    # access_type: should be one of the following:
    #              :pricing, :service, :concept_skus_uniq, :decorated
    # group action: should be one of the following:
    #              :min, :max, :avg
    # format: should be one of the following:
    #              :currency_cents, :currency
    #
    def initialize(field_name:, access_type:, access_field: nil, group: nil, format: nil)
      @field_name = field_name.to_sym
      @access_type = access_type.to_sym
      @access_field = access_field&.to_sym
      @group_action = group&.to_sym
      @format = format&.to_sym

      check_value('access_type', VALID_ACCESS_TYPES, @access_type)
      check_value('group', VALID_GROUP_ACTIONS, @group_action)
      check_value('format', VALID_FORMATS, @format)
    end

    def pricing?
      @access_type == :pricing
    end

    def service?
      @access_type == :service
    end

    def decorated?
      @access_type == :decorated
    end

    def concept_skus_uniq?
      @access_type == :concept_skus_uniq
    end

    def currency_cents?
      @format == :currency_cents
    end

    def currency?
      @format == :currency
    end

    def quoted_group_action
      @group_action.present? ? ":#{@group_action}" : 'nil'
    end

    def quoted_format
      @format.present? ? ":#{@format}" : 'nil'
    end

    def format_result(value)
      if currency?
        as_currency(value)
      elsif currency_cents?
        as_currency_cents(value)
      end
    end

    def self.group_and_format_results(result, group, format_type)
      result = apply_group(result, group.to_sym) if group.present?
      format_result(result, format_type)
    end

    def self.apply_group(result, action)
      if %i[min max].include? action
        result.public_send(action)
      elsif action == :avg
        result.empty? ? 0 : result.sum.fdiv(result.size)
      end
    end

    def self.format_result(value, type)
      if type&.to_sym == :currency
        as_currency(value)
      elsif type&.to_sym == :currency_cents
        as_currency_cents(value)
      else
        value
      end
    end

    def self.as_currency(value, type: 'USD')
      "#{value},#{type}"
    end

    def self.as_currency_cents(value)
      return 0 unless value

      (value * 100.0).to_i
    end

    def self.sku_pricing_result(service, access_field, group_action, format_type)
      result = service.sku_pricing_field_values(access_field)
      group_and_format_results(result, group_action, format_type)
    end

    def self.field_unique_values_result(service, access_field, group_action, format_type)
      result = service.field_unique_values(access_field)
      group_and_format_results(result, group_action, format_type)
    end

    def self.concept_skus_uniq_values(service, access_field, group_action, format_type)
      result = service.concept_skus_iterator_uniq(&access_field)
      group_and_format_results(result, group_action, format_type)
    end

    def self.decorated_skus_uniq_values(service, access_field, group_action, format_type)
      result = service.decorated_skus_iterator_uniq(&access_field)
      group_and_format_results(result, group_action, format_type)
    end

    private

    def check_value(field, valid_values, value)
      raise ArgumentError, error_msg(field, valid_values, value) unless valid_values.include?(value)
    end

    def error_msg(field, valid_values, value)
      "#{field} must be one of the following: #{valid_values.join(', ')}. value: #{value}"
    end
  end
end
