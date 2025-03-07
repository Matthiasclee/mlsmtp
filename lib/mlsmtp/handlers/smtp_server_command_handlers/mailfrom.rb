module SMTPServer
  module Handlers
    module SMTPServerCommandHandlers
      def self.mailfrom(context)
        mail_from = context.sender_addr
        command = SMTP::Command.new("MAIL FROM:", mail_from)

        context.send_data(command)

        Logger.log "Identified sender as #{mail_from}", origin: context.logger_origin, verbosity: 5

        response = context.read_response

        if response.status == 2
          Logger.log "Server accepted sender address", origin: context.logger_origin, verbosity: 5
          context.ready_for = :rcptto
          return true
        else
          Logger.log "Unexpected response `#{response.code}`", origin: context.logger_origin, verbosity: 5, type: :warn
          context.ready_for = :quit_negative
          return false
        end
      end
    end
  end
end
