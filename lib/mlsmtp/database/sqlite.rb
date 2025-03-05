module SMTPServer
  module Database
    class SQLite3Adapter
      def initialize(settings)
        @path = settings["path"]
        initialize_sqlite
      end

      def exec_sql(*sql)
        @database.execute *sql
      end

      def setup_database
      end

      private

      def initialize_sqlite
        @database = SQLite3::Database.open @path
      end
    end
  end
end
