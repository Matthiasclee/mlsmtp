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
            mid, uid, created_at, is_error_response, mail_from, rcpt_to, file_path = message

            destination = Transport::Destination.new(rcpt_to)

            message_data = File.read(file_path)

            if destination.local
              agent = Transport::LocalDeliveryAgent.new(
                user: destination.destination_user,
                message: message_data
              )

              agent.attempt_delivery
            end

            QueuedMessage.unqueue_uid(uid)
          end
        end
      end

      attr_reader :mod, :eq
    end
  end
end
