module SMTPServer
  module Handlers
    module SMTPCommandHandlers
      def self.rcptto(context, args)
        unless context.rcptto
          Logger.log "Received unexpected RCPT TO: command", origin: context.logger_origin, verbosity: 5, type: :warn

          message = SMTP::Response.new(
            status: :negative_permanent,
            category: :syntax,
            detail: 3,
            message: "5.5.1 Error: MAIL FROM: required"
          )
          context.send_response(message)
          return
        end

        Logger.log "Recipient added: `#{args[0]}`", origin: context.logger_origin, verbosity: 5

        context.rcptto << args[0]

        auth_handler = Transport::AuthorizationHandler.new(context)
        auth_handler.handle_authorization
      end
    end
  end
end
