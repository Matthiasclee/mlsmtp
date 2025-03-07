module SMTPServer
  module Handlers
    module SMTPServerCommandHandlers
      def self.quit(context, negative: false)
        command = SMTP::Command.new("QUIT")
        context.send_data(command)
        context.close

        Logger.log "Closed connection to server with #{negative ? "failure" : "success"}", origin: context.logger_origin, verbosity: 5, type: negative ? :warn : :info
      end
    end
  end
end
