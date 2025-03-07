module SMTPServer
  module Handlers
    module SMTPServerCommandHandlers
      def self.rcptto(context)
        rcpt_to = context.recipient_addr
        command = SMTP::Command.new("RCPT TO:", rcpt_to)

        context.send_data(command)

        Logger.log "Identified recipient as #{rcpt_to}", origin: context.logger_origin, verbosity: 5

        response = context.read_response

        if response.status == 2
          Logger.log "Server accepted recipient address", origin: context.logger_origin, verbosity: 5
          context.ready_for = :data
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
