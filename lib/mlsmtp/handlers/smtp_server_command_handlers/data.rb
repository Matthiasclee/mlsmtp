module SMTPServer
  module Handlers
    module SMTPServerCommandHandlers
      def self.data(context)
        command = SMTP::Command.new("DATA")

        context.send_data(command)

        Logger.log "Requested to send data", origin: context.logger_origin, verbosity: 5

        response = context.read_response

        if response.code == "354"
          Logger.log "Sending data", origin: context.logger_origin, verbosity: 5
          data = context.data
          data = data.split(/\r?\n/) if data.is_a?(String)

          data.each do |line|
            line = ".#{line}" if line[0] == ?.
            context.send_data(line)
          end

          context.send_data(?.)

          response = context.read_response
          if response.status == 2
            context.ready_for = :quit_positive
            return true
          else
            context.ready_for = :quit_negative
            return false
          end
        else
          Logger.log "Unexpected response `#{response.code}`", origin: context.logger_origin, verbosity: 5, type: :warn
          context.ready_for = :quit_negative
          return false
        end
      end
    end
  end
end
