module SMTPServer
  module Handlers
    module SMTPServerCommandHandlers
      def self.helo(context)
        heloname = Config.active["mailname"] 
        command = SMTP::Command.new("HELO", heloname)

        context.send_data(command)

        Logger.log "Self-Identified as `#{heloname}` with HELO", origin: context.logger_origin, verbosity: 5

        response = context.read_response

        if response.status == 2
          Logger.log "Server accepted HELO", origin: context.logger_origin, verbosity: 5
          context.ready_for = :mailfrom
          return true
        else
          Logger.log "Unexpected HELO response `#{response.code}`", origin: context.logger_origin, verbosity: 5, type: :warn
          context.ready_for = :quit_negative
          return false
        end
      end
    end
  end
end
