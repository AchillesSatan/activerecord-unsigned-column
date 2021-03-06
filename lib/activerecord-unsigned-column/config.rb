module ActiveRecord
  module UnsignedColumn
    class Config
      include ActiveSupport::Configurable

      config_accessor :primary_key_type

      configure do |config|
        config.primary_key_type = :integer
      end
    end
  end
end
