module SOLR
  class BaseSerializer < ActiveModel::Serializer
    # Sub-classes need to define which fields they should respond to
    # Probably want these to come from ProductCoreFields
    def serializable_fields
      []
    end

    def method_missing(method_name, *args, &block)
      return super unless serializable_field?(method_name)

      define_placeholder_method(method_name)
      public_send(method_name)
    end

    def serializable_field?(method_name)
      serializable_fields.find { |field| field[:name].to_sym == method_name }.present?
    end

    def respond_to_missing?(method_name, _include_private = false)
      return true if  serializable_field?(method_name)

      super
    end

    def define_placeholder_method(method_name)
      Rails.logger.warn("WARNING!!! ADDING PLACEHOLDER METHOD FOR #{self.class.name}##{method_name}")
      self.class.class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{method_name}
          nil
        end
      RUBY
    end
  end
end
