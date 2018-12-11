module SOLR
  # TODO: rename this class to DecoratedField
  class RollupField
    attr_reader :field_name, :field, :access_sub_type, :group_action, :format

    VALID_GROUP_ACTIONS = [:min, :max, :avg, :first, nil].freeze
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
      end
    end

    class << self
      def group_and_format_results(result, group, format_type)
        result = apply_group(result, group.to_sym) if group.present?
        format_result(result, format_type)
      end

      def apply_group(result, action)
        if %i[min max first].include? action
          result.public_send(action)
        elsif action == :avg
          result.empty? ? 0 : result.sum.fdiv(result.size)
        end
      end

      def format_result(value, type)
        if type&.to_sym == :currency
          as_currency(value)
        elsif type&.to_sym == :currency_cents
          as_currency_cents(value)
        elsif type&.to_sym == :percent_units
          as_percent_units(value)
        else
          value
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

      def sku_pricing_result(service, access_field, group_action, format_type)
        group_and_format_results(service.sku_pricing_field_values(access_field), group_action, format_type)
      end

      def concept_skus_any(service, field, group_action, format_type)
        group_and_format_results(service.concept_skus_any?(&field), group_action, format_type)
      end

      def concept_skus_uniq_values(service, field, group_action, format_type)
        group_and_format_results(service.concept_skus_iterator_uniq(&field), group_action, format_type)
      end

      def detect_value(object, field, group_action, format_type)
        value = object.concept_skus&.detect(&field)&.public_send(field)
        group_and_format_results(value, group_action, format_type)
      end
    end

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
