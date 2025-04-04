module SMTPServer
  module Handlers
    module SMTPServerCommandHandlers
      def self.ehlo(context, attempt_starttls: true)
        heloname = Config.active["mailname"] 
        command = SMTP::Command.new("EHLO", heloname)

        context.send_data(command)

        Logger.log "Self-Identified as `#{heloname}` with EHLO", origin: context.logger_origin, verbosity: 5

        response = context.read_response

        if response.status == 2
          Logger.log "Server accepted EHLO", origin: context.logger_origin, verbosity: 5

          if response.message.include?("STARTTLS") && attempt_starttls
            context.ready_for = :starttls
          else
            context.ready_for = :mailfrom
          end
          return true
        else
          Logger.log "Server rejected EHLO with code `#{response.code}, trying HELO`", origin: context.logger_origin, verbosity: 5, type: :warn
          context.ready_for = :helo
          return false
        end
      end
    end
  end
end
