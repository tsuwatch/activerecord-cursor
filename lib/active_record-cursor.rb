require 'active_record'

ActiveSupport.on_load(:active_record) do
  require 'active_record/cursor'
  ActiveRecord::Base.send(:include, ActiveRecord::Cursor)
end
