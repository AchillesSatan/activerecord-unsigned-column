module ActiveRecord
  module ConnectionAdapters
    class TableDefinition
      def unsigned_bigint(*args)
        options = args.extract_options!
        column_names = args
        type = :unsigned_bigint
        column_names.each { |name| column(name, type, options) }
      end

      def unsigned(*args)
        options = args.extract_options!
        column_names = args
        type = :unsigned
        column_names.each { |name| column(name, type, options) }
      end
    end

    class Table
      def unsigned_bigint(*args)
        options = args.extract_options!
        options.merge(limit: 8)

        unsigned(args, options)
      end

      def unsigned(*args)
        options = args.extract_options!
        column_names = args
        type = :unsigned
        column_names.each do |name|
          column = ColumnDefinition.new(@base, name, type)
          if options[:limit]
            column.limit = options[:limit]
          elsif native[type].is_a?(Hash)
            column.limit = native[type][:limit]
          end
          @base.add_column(@table_name, name, column.sql_type, options)
        end
      end
    end

    module TypeToSql
      def type_to_sql(type, limit = nil, precision = nil, scale = nil)
        if type == :unsigned
          case limit
          when 1; 'tinyint unsigned'
          when 2; 'smallint unsigned'
          when 3; 'mediumint unsigned'
          when nil, 4, 10; 'int(10) unsigned'
          when 5..8; 'bigint unsigned'
          else raise(ActiveRecordError, "No integer type has byte size #{limit}")
          end
        else
          super
        end
      end
    end

    module SimplifiedType
      def simplified_type(field_type)
        if field_type =~ /unsigned/i
          :unsigned
        else
          super
        end
      end
    end

    class AbstractMysqlAdapter
      if ActiveRecord::VERSION::STRING < "4.2.0"
        def type_to_sql_with_unsigned(type, limit = nil, precision = nil, scale = nil)
          if type == :unsigned
            case limit
            when 1; 'tinyint unsigned'
            when 2; 'smallint unsigned'
            when 3; 'mediumint unsigned'
            when nil, 4, 10; 'int(10) unsigned'
            when 5..8; 'bigint unsigned'
            else raise(ActiveRecordError, "No integer type has byte size #{limit}")
            end
          else
            type_to_sql_without_unsigned(type, limit, precision, scale)
          end
        end
        alias_method_chain :type_to_sql, :unsigned

        class Column
          def simplified_type_with_unsigned(field_type)
            if field_type =~ /unsigned/i
              :unsigned
            else
              simplified_type_without_unsigned(field_type)
            end
          end
          alias_method_chain :simplified_type, :unsigned

          def type_cast(value)
            if type == :unsigned
              return nil if value.nil?
              return coder.load(value) if encoded?
              value.to_i rescue value ? 1 : 0
            else
              super
            end
          end
        end

        NATIVE_DATABASE_TYPES.merge!(
          :unsigned => { :name => 'int(10) unsigned', :limit => 4 },
          :unsigned_bigint => { :name => 'bigint(20) unsigned' }
        )

      else
        prepend TypeToSql

        class Column
          prepend SimplifiedType

          def type_cast(value)
            if type == :unsigned
              return nil if value.nil?
              return coder.load(value) if encoded?
              value.to_i rescue value ? 1 : 0
            else
              super
            end
          end
        end

        NATIVE_DATABASE_TYPES.merge!(
          :unsigned => { :name => 'int(10) unsigned' },
          :unsigned_bigint => { :name => 'bigint(20) unsigned' }
        )
      end
    end
  end
end
