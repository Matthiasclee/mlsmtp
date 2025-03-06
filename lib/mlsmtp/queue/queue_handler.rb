module SMTPServer
  module Queue
    class QueueHandler
      def initialize(mod:, eq:)
        @mod = mod
        @eq = eq
      end

      def run
        while true
          queued_messages = QueuedMessage.find_by_mod(mod: @mod, eq: @eq)
          queued_messages.each do |message|
            mid, uid, is_error_response, created_at, mail_from, rcpt_to, file_path = message

            destination = Transport::Destination.new(rcpt_to)

            message_data = File.read(file_path)

            if destination.local
              agent = Transport::LocalDeliveryAgent.new(
                user: destination.destination_user,
                message: message_data
              )

              begin
                agent.attempt_delivery
              rescue
                error_email = Email::ErrorEmails::DeliveryFailed.new(
                  original_from: mail_from,
                  original_to: rcpt_to
                )

                err_email_text = error_email.prepared_email

                if is_error_response == 0 && err_email_text
                  queued_response = QueuedMessage.new(
                    mail_from: Config.active["contact_email"],
                    rcpt_to: mail_from,
                    message: err_email_text,
                    error_response: true
                  )

                  STDOUT.puts queued_response.queue.to_s
                end
              end
            end

            QueuedMessage.unqueue_uid(uid)
          end
        end
      end

      attr_reader :mod, :eq
    end
  end
end
