require "activerecord-unsigned-column/config"
require "activerecord-unsigned-column/engine"

module ActiveRecord
  module UnsignedColumn
    def self.config
      ActiveRecord::UnsignedColumn::Config.config
    end
  end
end

# load Rails/Railtie
begin
  require 'rails'
rescue LoadError
  # do nothing
end

if defined? Rails
  require 'activerecord-unsigned-column/railtie'
end
