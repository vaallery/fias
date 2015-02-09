module Fias
  module Import
    class Copy
      def initialize(table_name, dbf, types = [])
        @connection = ActiveRecord::Base.connection
        @table_name = table_name
        @dbf = dbf
        @encoder = PgDataEncoder::EncodeForCopy.new(
          column_types: map_types(types)
        )
      end

      def encode
        @dbf.each do |record|
          @encoder.add(record.to_a)
          yield if block_given?
        end
      end

      def perform
        prepare
        start
        copy
        finish
      end

      private

      def map_types(types)
        types = types.map do |name, type|
          index = columns.index(name.to_s)
          [index, type] if index
        end
        Hash[*types.compact.flatten]
      end

      def columns
        @columns ||= @dbf.columns.map(&:name).map(&:downcase)
      end

      def columns_s
        columns.map { |c| %("#{c}") }.join(',')
      end

      def prepare
        @connection.execute(
          "TRUNCATE TABLE #{@table_name}; SET client_min_messages TO warning;"
        )
      end

      def start
        raw_connection.exec(
          "COPY #{@table_name} (#{columns_s}) FROM STDIN BINARY\n"
        )
      end

      def copy
        io = @encoder.get_io

        while (line = io.readpartial(BLOCK_SIZE))
          raw_connection.put_copy_data(line)
        end
      rescue EOFError => _e
        return
      end

      def finish
        raw_connection.put_copy_end

        while (res = raw_connection.get_result)
          result_status = res.res_status(res.result_status)
          unless result_status == 'PGRES_COMMAND_OK'
            fail "Import failure: #{result_status}"
          end
        end
      end

      def raw_connection
        @raw_connection ||= @connection.pool.checkout.raw_connection
      end

      BLOCK_SIZE = 10_240
    end
  end
end