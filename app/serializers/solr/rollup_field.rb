module SOLR
  # TODO: rename this class to DecoratedField
  class RollupField
    attr_reader :field_name, :field, :access_sub_type, :group_action, :format

    VALID_GROUP_ACTIONS = [:min, :max, :avg, :first, :sum, nil].freeze
    VALID_FORMATS = [:currency, :currency_cents, :percent_units, nil].freeze

    # Defines how we roll up the field
    # field_name: the name of the field we want written to SOLR
    # group action: should be one of the following:
    #              :min, :max, :avg
    # format: should be one of the following:
    #              :currency_cents, :currency
    #
    def initialize(options)
      validate_options(options)

      @field_name = options[:field_name].to_sym
      @access_sub_type = options[:access_sub_type]&.to_sym
      @field = options[:field]&.to_sym
      @group_action = options[:group]&.to_sym
      @format = options[:format]&.to_sym
    end

    def currency_cents?
      @format == :currency_cents
    end

    def currency?
      @format == :currency
    end

    def percent_units?
      @format == :percent_units
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
      elsif percent_units?
        as_percent_units(value)
      else
        value
      end
    end

    def group_and_format(result)
      result = apply_group(result, @group_action) if @group_action.present?
      format_result(result)
    end

    def apply_group(result, action)
      if %i[min max first].include? action
        result.public_send(action)
      elsif action == :sum
        result.compact.empty? ? 0 : result.compact.sum
      elsif action == :avg
        result.empty? ? 0 : result.sum.fdiv(result.size)
      end
    end

    def as_currency(value, type: 'USD')
      "#{value},#{type}"
    end

    def as_currency_cents(value)
      return 0 unless value

      (value * 100.0).to_i
    end

    # as percent is the same implementation as currency to cents conversion
    alias as_percent_units as_currency_cents

    private

    def validate_options(options)
      missing_keys = %i[field_name] - options.keys
      raise ArgumentError, "Missing keys #{missing_keys.join(',')}" unless missing_keys.empty?

      check_value('group', VALID_GROUP_ACTIONS, options[:group_action]&.to_sym)
      check_value('format', VALID_FORMATS, options[:format]&.to_sym)
    end

    def check_value(field, valid_values, value)
      raise ArgumentError, error_msg(field, valid_values, value) unless valid_values.include?(value)
    end

    def error_msg(field, valid_values, value)
      "#{field} must be one of the following: #{valid_values.join(', ')}. value: #{value}"
    end
  end
end
