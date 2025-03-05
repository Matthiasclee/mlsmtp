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
        Database::Active.exec_sql *build_sql(
          mail_from: @mail_from,
          rcpt_to: @rcpt_to,
          message: @message
        )
      end

      attr_reader :mail_from, :rcpt_to, :message, :queued, :message_id

      private

      def build_sql(mail_from:, rcpt_to:, message:)
        ["INSERT INTO queued_messages (created_at, mail_from, rcpt_to, file_path) VALUES (?, ?, ?, ?)", 
            Time.now.to_i, 
            mail_from, 
            rcpt_to, 
            get_file_path]
      end

      def get_file_path
        loop do
          path = Config.active["queue"]["queued_mail_dir"] + "/#{rand(1000000000000000000..9999999999999999999)}"
          return path unless File.exist?(path)
        end
      end
    end
  end
end
