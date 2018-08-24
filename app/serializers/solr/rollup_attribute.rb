module SOLR
  module RollupAttribute
    extend ActiveSupport::Concern

    module ClassMethods
      # Defines how we roll up the field just passes through to the RollupField but this is the entrypoint / DSL
      # field_name: the name of the field we want written to SOLR
      # access_type: should be one of the following:
      #              :pricing, :service, :concept_skus_uniq, :decorated
      # group action: should be one of the following:
      #              :min, :max, :avg
      # format: should be one of the following:
      #              :currency_cents, :currency
      #
      # rubocop:disable all
      def rollup(field_name, **args)
        field = RollupField.new(args.merge(field_name: field_name))

        if field.pricing?
          define_pricing_method(field)
        elsif field.service?
          define_field_unique_method(field)
        elsif field.decorated?
          define_decorated_unique_method(field)
        elsif field.concept_skus_uniq?
          define_concept_skus_method(field)
        elsif field.concept_skus_any?
          define_concept_skus_any_method(field)
        elsif field.detect?
          define_detect_method(field)
        end
      end
      # rubocop:enable all

      def define_pricing_method(field)
        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{field.field_name}
            RollupField.sku_pricing_result(service, :#{field.access_field}, #{field.quoted_group_action}, #{field.quoted_format})
          end
        RUBY
      end

      def define_field_unique_method(field)
        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{field.field_name}
            RollupField.field_unique_values_result(service, :#{field.access_field}, #{field.quoted_group_action}, #{field.quoted_format})
          end
        RUBY
      end

      def define_decorated_unique_method(field)
        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{field.field_name}
            RollupField.decorated_skus_uniq_values(service, :#{field.access_field}, #{field.quoted_group_action}, #{field.quoted_format})
          end
        RUBY
      end

      def define_concept_skus_method(field)
        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{field.field_name}
            RollupField.concept_skus_uniq_values(service, :#{field.access_field}, #{field.quoted_group_action}, #{field.quoted_format})
          end
        RUBY
      end

      def define_concept_skus_any_method(field)
        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{field.field_name}
            RollupField.concept_skus_any(service, :#{field.access_field}, #{field.quoted_group_action}, #{field.quoted_format})
          end
        RUBY
      end

      def define_detect_method(field)
        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{field.field_name}
            RollupField.detect_value(object, :#{field.access_field}, #{field.quoted_group_action}, #{field.quoted_format})
          end
        RUBY
      end
    end
  end
end
