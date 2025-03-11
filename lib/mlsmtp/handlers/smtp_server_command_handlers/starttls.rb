module SMTPServer
  module Handlers
    module SMTPServerCommandHandlers
      def self.starttls(context)
        Logger.log "Attempting to upgrade to TLS", origin: context.logger_origin, verbosity: 5

        command = SMTP::Command.new("STARTTLS")
        context.send_data(command)

        response = context.read_response

        if response.code != "220"
          Logger.log "Server rejected STARTTLS request with code `#{response.code}`", origin: context.logger_origin, verbosity: 5, type: :warn
          context.ready_for = :mailfrom
          return
        end

        begin
          ssl_context = OpenSSL::SSL::SSLContext.new
          ssl_context.verify_mode = OpenSSL::SSL::VERIFY_NONE
          ssl_socket = OpenSSL::SSL::SSLSocket.new(context.tcp_server, ssl_context)
          ssl_socket.sync_close = true
          ssl_socket.connect

          context.server = ssl_socket

          Logger.log "Upgraded to TLS", origin: context.logger_origin, verbosity: 5
        rescue OpenSSL::SSL::SSLError
          Logger.log "Failed upgrading to TLS", origin: context.logger_origin, verbosity: 5, type: :warn
        end

        context.ready_for = :mailfrom
      end
    end
  end
end
