module SMTPServer
  module Queue
    class QueuedMessage
      def initialize(mail_from:, rcpt_to:, message:)
        @mail_from = mail_from
        @rcpt_to = rcpt_to
        @message = message
        @message_id = nil
        @queued = false
      end

      def queue
        return false unless Database.active

        unless @queued
          @file_path, @message_uid = get_path_and_id

          File.write(@file_path, @message)

          Database.active.exec_sql *build_sql(
            mail_from: @mail_from,
            message_uid: @message_uid,
            rcpt_to: @rcpt_to,
            message: @message,
            file_path: @file_path
          )

          @queued = true
        end

        return [ @file_path, @message_uid ]
      end

      def self.find_by_mod(mod: 1, eq: 0)
        return nil unless Database.active

        Database.active.exec_sql(
          "SELECT * FROM queued_messages WHERE message_id % ? = ?",
          [
            mod,
            eq
          ]
        )
      end

      def self.find_by_mid(mid)
        return nil unless Database.active

        Database.active.exec_sql(
          "SELECT * FROM queued_messages WHERE message_id = ?",
          mid
        )
      end

      def self.find_by_uid(uid)
        return nil unless Database.active

        Database.active.exec_sql(
          "SELECT * FROM queued_messages WHERE message_uid = ?",
          uid
        )
      end

      def self.unqueue_uid(uid)
        return nil unless Database.active
        messages = find_by_uid(uid)
        return if messages.empty?

        if Config.active["queue"]["remove_on_unqueue"]
          path = messages[0][5]
          File.delete(path) if File.exist?(path)
        end

        Database.active.exec_sql(
          "DELETE FROM queued_messages WHERE message_uid = ?",
          uid
        )
      end

      attr_reader :mail_from, :rcpt_to, :message, :queued, :message_id, :file_path, :message_uid

      private

      def build_sql(message_uid:, mail_from:, rcpt_to:, message:, file_path:)
        [
          "INSERT INTO queued_messages (message_uid, created_at, mail_from, rcpt_to, file_path) VALUES (?, ?, ?, ?, ?)",
          [
            message_uid,
            Time.now.to_i, 
            mail_from, 
            rcpt_to, 
            file_path
          ]
        ]
      end

      def get_path_and_id
        loop do
          message_uid = rand(1000000000000000000..9999999999999999999)
          path = Config.active["queue"]["queued_mail_dir"] + "/#{message_uid}.eml"
          return [ path, message_uid ] unless File.exist?(path)
        end
      end
    end
  end
end
