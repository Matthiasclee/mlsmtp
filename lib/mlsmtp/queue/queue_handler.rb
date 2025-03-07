module SMTPServer
  module Queue
    class QueueHandler
      def initialize(mod:, eq:)
        @mod = mod
        @eq = eq

        @origin = "Worker #{eq}"
      end

      def run
        while true
          queued_messages = QueuedMessage.find_by_mod(mod: @mod, eq: @eq)
          queued_messages.each do |message|
            mid, uid, is_error_response, created_at, mail_from, rcpt_to, file_path = message
            origin = "Worker #{@eq}: #{uid}"

            Logger.log "Attempting to deliver queued message to `#{rcpt_to}`", origin: origin, verbosity: 2

            destination = Transport::Destination.new(rcpt_to)

            message_data = File.read(file_path)

            if destination.local
              Logger.log "Destination is local, using local delivery agent", origin: origin, verbosity: 3

              agent = Transport::LocalDeliveryAgent.new(
                user: destination.destination_user,
                message: message_data
              )
            else
              Logger.log "Destination is remote, using remote delivery agent", origin: origin, verbosity: 3

              agent = Transport::RemoteDeliveryAgent.new(
                message: message_data,
                destination: destination,
                sender: mail_from,
                origin: origin
              )
            end

            begin
              agent.attempt_delivery
              Logger.log "Message delivered successfully to #{"mailbox " if destination.local}`#{destination.destination_user}`", origin: origin, verbosity: 3
            rescue => e
              generator = Email::ErrorEmailGenerator.new(
                e,
                origin: origin,
                mail_from: mail_from,
                rcpt_to: rcpt_to,
                is_error_response: is_error_response
              )
              generator.queue_email
            end

            QueuedMessage.unqueue_uid(uid)
            Logger.log "Removed message #{uid} from queue", origin: origin, verbosity: 3
          end
        end
      end

      attr_reader :mod, :eq
    end
  end
end
