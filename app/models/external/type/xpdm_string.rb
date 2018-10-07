module External
  module Type
    class XPDMString < ActiveModel::Type::String
      HTML_TAG_MATCHER = /&\w+;/

      def deserialize(value)
        unicode_value = value.encode('UTF-8', 'ISO-8859-1')

        if HTML_TAG_MATCHER.match?(unicode_value)
          HTMLEntities::Decoder.new('xhtml1').decode(unicode_value)
        else
          unicode_value
        end
      rescue
        value
      end
    end
  end
end
