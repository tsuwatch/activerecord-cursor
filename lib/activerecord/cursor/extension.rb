require 'activerecord/cursor/model_extension'

module ActiveRecord
  module Cursor
    module Extension
      extend ActiveSupport::Concern

      module ClassMethods
        def inherited(kls)
          super
          kls.public_send(:include, ActiveRecord::Cursor::ModelExtension) if kls.superclass == ActiveRecord::Base
        end
      end

      included do
        descendants.each do |kls|
          kls.public_send(:include, ActiveRecord::Cursor::ModelExtension) if kls.superclass == ApplicationRecord
        end
      end
    end
  end
end
