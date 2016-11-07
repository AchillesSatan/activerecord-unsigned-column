require 'activerecord-unsigned-column/base'

module ActiveRecord
  module ConnectionAdapters
    class TableDefinition
      def references(*args)
        options = args.extract_options!
        polymorphic = options.delete(:polymorphic)
        args.each do |col|
          column("#{col}_id", UnsignedColumn.config.primary_key_type, options)
          column("#{col}_type", :string, polymorphic.is_a?(Hash) ? polymorphic : options) unless polymorphic.nil?
        end
      end
      alias :belongs_to :references
    end

    class Table
      def references(*args)
        options = args.extract_options!
        polymorphic = options.delete(:polymorphic)
        args.each do |col|
          @base.add_column(@table_name, "#{col}_id", UnsignedColumn.config.primary_key_type, options)
          @base.add_column(@table_name, "#{col}_type", :string, polymorphic.is_a?(Hash) ? polymorphic : options) unless polymorphic.nil?
        end
      end
      alias :belongs_to :references
    end

    module TypeToSql
      def type_to_sql(type, limit = nil, precision = nil, scale = nil, unsigned = nil)
        if type == :primary_key
          column_type_sql = type_to_sql_without_primary_key(UnsignedColumn.config.primary_key_type, limit, precision, scale)
          column_type_sql << ' DEFAULT NULL auto_increment PRIMARY KEY'
        else
          super
        end
      end
    end

    class AbstractMysqlAdapter
      prepend TypeToSql
    end
  end
end
