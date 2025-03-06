module SMTPServer
  module Handlers
    module SMTPCommandHandlers
      def self.quit(context)
        response = SMTP::Response.new(
          status: :positive_completed,
          category: :connections,
          detail: 1,
          message: "Closing connection"
        )
        context.send_response(response)
        context.close

        Logger.log "Client disconnected with QUIT command", origin: context.logger_origin, verbosity: 5
      end
    end
  end
end
