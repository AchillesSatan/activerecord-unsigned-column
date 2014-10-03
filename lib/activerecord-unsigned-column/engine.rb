module ActiveRecord
  module UnsignedColumn
    class Engine < ::Rails::Engine
      isolate_namespace UnsignedColumn

      config.unsigned_column = ActiveRecord::UnsignedColumn::Config
    end
  end
end
