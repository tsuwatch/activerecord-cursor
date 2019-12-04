module ActiveRecord
  module Cursor
    class Params
      attr_reader :cursor

      def initialize(cursor)
        @cursor = cursor
      end

      def self.decode(cursor)
        if cursor.nil?
          new nil
        else
          new YAML.safe_load(
            Base64.urlsafe_decode64(cursor),
            [Symbol, Time, ActiveSupport::TimeZone, ActiveSupport::TimeWithZone],
            [],
            true
          ).with_indifferent_access
        end
      rescue Psych::SyntaxError
        raise InvalidCursor
      end

      def encoded
        Base64.urlsafe_encode64 cursor.to_yaml
      end

      def value
        @cursor
      end
    end
  end
end
