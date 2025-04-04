module SMTPServer
  module Handlers
    class SMTPServerHandler
      def initialize(context)
        @context = context
      end

      def handle_client(context)
        server_banner = context.read_response

        Logger.log "Server ready: #{server_banner.message}", origin: context.logger_origin, verbosity: 4

        while true
          ready_for = context.ready_for
          case ready_for
          when :ehlo
            SMTPServerCommandHandlers.ehlo(context)
          when :helo
            SMTPServerCommandHandlers.helo(context)
          when :re_ehlo
            SMTPServerCommandHandlers.ehlo(context, attempt_starttls: false)
          when :starttls
            SMTPServerCommandHandlers.starttls(context)
          when :mailfrom
            SMTPServerCommandHandlers.mailfrom(context)
          when :rcptto
            SMTPServerCommandHandlers.rcptto(context)
          when :data
            SMTPServerCommandHandlers.data(context)
          when :quit_positive
            SMTPServerCommandHandlers.quit(context)
            return true
          when :quit_negative
            SMTPServerCommandHandlers.quit(context, negative: true)
            return false
          end
        end
      end
    end
  end
end
