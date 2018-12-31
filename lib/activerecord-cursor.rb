require 'active_record'

ActiveSupport.on_load(:active_record) do
  require 'activerecord/cursor'
  ActiveRecord::Base.send(:include, ActiveRecord::Cursor)
end
