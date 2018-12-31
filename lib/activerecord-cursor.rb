require 'active_record'
require 'activerecord/cursor/version'

module ActiveRecord
  module Cursor
    class InvalidCursor < StandardError; end
  end
end

ActiveSupport.on_load(:active_record) do
  require 'activerecord/cursor/extension'
  ActiveRecord::Base.send(:include, ActiveRecord::Cursor::Extension)
end
