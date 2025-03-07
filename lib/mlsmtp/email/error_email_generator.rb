module SMTPServer
  module Email
    class ErrorEmailGenerator
      def initialize(error, origin)
        @error = error
        @origin = origin
      end

      def queue_email
        error = :other_internal
        error = "bad_mailbox" if @error.class == SMTPServer::Errors::NonexistentMailboxError
        error = "delivery_failed" if @error.class == SMTPServer::Errors::ServerRejectionError

        if error == :other_internal
          Logger.log "Unexpected error when delivering email: #{e}", origin: @origin, verbosity: 3, type: :warn
        else
          Logger.log "Error delivering email: `#{@error}`", origin: @origin, verbosity: 3, type: :warn

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

            Logger.log "Queued error response as `#{id}`", origin: @origin, verbosity: 4
          elsif is_error_response == 1
            Logger.log "Original message was an error response; not sending another error response", origin: @origin, verbosity: 4
          end
        end
      end
    end
  end
end
