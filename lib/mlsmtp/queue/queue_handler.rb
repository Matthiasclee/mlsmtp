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
              error = :other_internal
              error = "bad_mailbox" if e.class == SMTPServer::Errors::NonexistentMailboxError

              if error == :other_internal
                Logger.log "Unexpected error when delivering email: #{e}", origin: origin, verbosity: 3, type: :warn
              else
                Logger.log "Error delivering email: `#{error}`", origin: origin, verbosity: 3, type: :warn

                error_email = Email::ErrorEmail.new(
                  original_from: mail_from,
                  original_to: rcpt_to,
                  email_name: error
                )

                err_email_text = error_email.prepared_email

                if is_error_response == 0 && err_email_text
                  queued_response = QueuedMessage.new(
                    mail_from: Config.active["contact_email"],
                    rcpt_to: mail_from,
                    message: err_email_text,
                    error_response: true
                  )

                  id = queued_response.queue[1]

                  Logger.log "Queued error response as `#{id}`", origin: origin, verbosity: 4
                elsif is_error_response == 1
                  Logger.log "Original message was an error response; not sending another error response", origin: origin, verbosity: 4
                end
              end
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
