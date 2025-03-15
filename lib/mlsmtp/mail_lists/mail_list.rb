module SMTPServer
  module MailLists
    class MailList
      def initialize(id)
        @id = id
      end

      def expand
        return nil unless Database.active

        Database.active.exec_sql(
          "SELECT email FROM list_memberships WHERE list_id = ?",
          @id
        )
      end

      def add_membership(email)
        return nil unless Database.active

        begin
          Database.active.exec_sql(
            "INSERT INTO list_memberships (email, list_id) VALUES (?, ?)",
            [
              email,
              @id
            ]
          )

          return true
        rescue SQLite3::ConstraintException
          return false
        end
      end

      def remove_membership(email)
        return nil unless Database.active

        Database.active.exec_sql(
          "DELETE FROM list_memberships WHERE (email = ? AND list_id = ?)",
          [
            email,
            @id
          ]
        )
      end

      def delete
        return nil unless Database.active

        Database.active.exec_sql(
          "DELETE FROM mail_lists WHERE id = ?",
          [
            @id
          ]
        )
      end

      def self.all
        return nil unless Database.active

        Database.active.exec_sql(
          "SELECT * FROM mail_lists"
        )
      end

      def self.create(name)
        begin
          Database.active.exec_sql(
            "INSERT INTO mail_lists (name) VALUES (?)",
            [
              name
            ]
          )
        rescue SQLite3::ConstraintException
          true
        end

        return find_by_name(name)
      end

      def self.find_by_id(id)
        return nil unless Database.active

        list = Database.active.exec_sql(
          "SELECT * FROM mail_lists WHERE id = ?",
          [
            id,
          ]
        ).first
        
        return list ? new(list[0]) : nil
      end

      def self.find_by_name(name)
        return nil unless Database.active

        list = Database.active.exec_sql(
          "SELECT * FROM mail_lists WHERE name = ?",
          [
            name,
          ]
        ).first

        return list ? new(list[0]) : nil
      end
    end
  end
end
