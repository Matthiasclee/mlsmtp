module SMTPServer
  module Database
    class SQLite3Adapter
      def initialize(settings)
        @path = settings["path"]
        @setup_file = settings["db_setup"]
        @busy_timeout = settings["busy_timeout"]
        initialize_sqlite

        setup_database if settings["autocreate_db"]
      end

      def exec_sql(*sql)
        @database.execute *sql
      end

      def setup_database
        @database.execute File.read(@setup_file)
      end

      private

      def set_busy_timeout(timeout)
        exec_sql("PRAGMA busy_timeout = #{timeout};")
      end

      def initialize_sqlite
        @database = SQLite3::Database.open @path
        set_busy_timeout(@busy_timeout)
      end
    end
  end
end
