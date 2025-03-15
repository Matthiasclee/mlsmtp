module SMTPServer
  module Queue
    class QueueHandler
      @@delivery_timeout = Config.active["transport"]["delivery_timeout"]
      @@retry_interval = Config.active["transport"]["retry_interval"]

      def initialize(mod:, eq:)
        @mod = mod
        @eq = eq

        @origin = "Worker #{eq}"
      end

      def run
        while true
          queued_messages = QueuedMessage.find_by_mod(mod: @mod, eq: @eq)
          queued_messages.each do |message|
            mid, uid, is_error_response, created_at, mail_from, rcpt_to, file_path, retries, try_at = message
            next if try_at > Time.now.to_i

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
              Timeout.timeout(@@delivery_timeout) do
                agent.attempt_delivery
                Logger.log "Message delivered successfully to #{"mailbox " if destination.local}`#{destination.destination_user}`", origin: origin, verbosity: 3
              end
            rescue => e
              if retries <= 0
                generator = Email::ErrorEmailGenerator.new(
                  e,
                  origin: origin,
                  mail_from: mail_from,
                  rcpt_to: rcpt_to,
                  is_error_response: is_error_response
                )
                generator.queue_email
              else
                Logger.log "Error delivering email: `#{e}`, trying #{retries} more time#{?s unless retries == 1}", origin: origin, verbosity: 3, type: :warn

                retry_message = QueuedMessage.new(
                  mail_from: mail_from,
                  rcpt_to: rcpt_to,
                  message: message_data,
                  retries: retries-1,
                  try_at: Time.now.to_i + @@retry_interval
                )

                quid = retry_message.queue[1]
                Logger.log "Queued retry message as #{quid}", origin: origin, verbosity: 3
              end
            end

            QueuedMessage.unqueue_uid(uid)
            Logger.log "Removed message #{uid} from queue", origin: origin, verbosity: 3
          end
        end
      end
    end

    attr_reader :mod, :eq
  end
end
