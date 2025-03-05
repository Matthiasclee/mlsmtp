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
        unless @queued
          @file_path, @message_uid = get_path_and_id

          File.write(@file_path, @message)

          Database::Active.exec_sql *build_sql(
            mail_from: @mail_from,
            rcpt_to: @rcpt_to,
            message: @message,
            file_path: @file_path
          )

          @queued = true
        end

        return [ @file_path, @message_uid ]
      end

      def self.find(mod: 1, eq: 0)
        Database.active.exec_sql(
          "SELECT * FROM queued_messages WHERE message_id % ? = ?",
          [
            mod,
            eq
          ]
        )
      end

      attr_reader :mail_from, :rcpt_to, :message, :queued, :message_id, :file_path, :message_uid

      private

      def build_sql(mail_from:, rcpt_to:, message:, file_path:)
        [
          "INSERT INTO queued_messages (created_at, mail_from, rcpt_to, file_path) VALUES (?, ?, ?, ?)",
          [
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
