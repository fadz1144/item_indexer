module API
  module Messages
    # = Message Base
    #
    # Message objects represent messages received. The underlying message might be in XML or JSON, the message classes
    # abstract that away.
    #
    # Each message class must respond to method <tt>records</tt>. The default implementation uses methods
    # <tt>to_active_record</tt> and <tt>children</tt> to return a list of active record instances. The
    # <tt>to_active_record</tt> method requires class-method <tt>model_class</tt> to return the name of the model used
    # to store the message and method <tt>model_attributes</tt> to return the attributes used to instantiate the
    # model. In order to use the default implementation, a model only needs implement <tt>model_class</tt>
    # and optionally <tt>children</tt> if there are any.
    class Base
      def initialize(data)
        @data = data
      end

      def model_attributes
        @data.slice(*self.class.model_class.column_names)
      end

      def records
        [to_active_record] + children.map(&:records)
      end

      def children
        []
      end

      def to_active_record
        self.class.model_class.new(model_attributes)
      end
    end
  end
end
