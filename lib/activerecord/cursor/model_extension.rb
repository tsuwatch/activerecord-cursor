require 'activerecord/cursor/params'

module ActiveRecord
  module Cursor
    module ModelExtension
      extend ActiveSupport::Concern

      module ClassMethods
        def cursor(options = {})
          @options = default_options.merge!(options).symbolize_keys!
          @options[:direction] =
            if @options.key?(:start) || @options.key?(:stop)
              @options.key?(:start) ? :start : :stop
            end
          @cursor = Params.decode(@options[@options[:direction]]).value
          @records = on_cursor.in_order.limit(@options[:size] + 1)
          set_cursor
          @records
        rescue ActiveRecord::StatementInvalid
          raise Cursor::InvalidCursor
        end

        def next_cursor
          @next
        end

        def prev_cursor
          @prev
        end

        def on_cursor
          if @cursor.nil?
            where(nil)
          else
            where(
              "(#{column} = ? AND #{table_name}.id #{sign_of_inequality} ?) OR (#{column} #{sign_of_inequality} ?)",
              @cursor[:key],
              @cursor[:id],
              @cursor[:key]
            )
          end
        end

        def in_order
          reorder("#{column} #{by}", "#{table_name}.id #{by}")
        end

        private

        def default_options
          { key: 'id', reverse: false, size: 1 }
        end

        def column
          "#{table_name}.#{@options[:key]}"
        end

        def sign_of_inequality
          case @options[:reverse]
          when true
            @options[:direction] == :start ? '<' : '>'
          when false
            @options[:direction] == :start ? '>' : '<'
          end
        end

        def by
          direction = @options[:direction]
          case @options[:reverse]
          when true
            direction == :start || direction.nil? ? 'desc' : 'asc'
          when false
            direction == :start || direction.nil? ? 'asc' : 'desc'
          end
        end

        def set_cursor
          @next = nil
          @prev = nil
          if @options[:direction] == :start
            set_cursor_on_start
          elsif @options[:direction] == :stop
            set_cursor_on_stop
          elsif @records.size == @options[:size] + 1
            @records = @records.limit(@options[:size])
            @next = generate_cursor(@records[@records.size - 1])
          end
        end

        def set_cursor_on_start
          record = @records[0]
          @prev = generate_cursor(record) if record
          size = @records.size
          @records = @records.limit(@options[:size])
          return unless size == @options[:size] + 1

          @next = generate_cursor(@records[@records.size - 1])
        end

        def set_cursor_on_stop
          record = @records[0]
          @next = generate_cursor(record) if record
          size = @records.size
          @records = @records.limit(@options[:size]).sort do |a, b|
            b.public_send(@options[:key]) <=> a.public_send(@options[:key])
          end
          return unless size == @options[:size] + 1

          @prev = generate_cursor(record)
        end

        def generate_cursor(record)
          Params.new(id: record.id, key: record.public_send(@options[:key])).encoded
        end
      end
    end
  end
end
