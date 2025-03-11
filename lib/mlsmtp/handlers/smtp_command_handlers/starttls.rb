module SMTPServer
  module Handlers
    module SMTPCommandHandlers
      def self.starttls(context)
        unless context.starttls_support
          response = SMTP::Response.new(
            status: :negative_permanent,
            category: :syntax,
            detail: 2,
            message: "Error: command not recognized"
          )
          context.send_response(response)

          Logger.log "This context does not support STARTTLS", origin: context.logger_origin, verbosity: 5, type: :warn

          return
        end

        if context.using_starttls
          response = SMTP::Response.new(
            status: :negative_permanent,
            category: :syntax,
            detail: 3,
            message: "Error: already using STARTTLS"
          )
          context.send_response(response)

          Logger.log "Already using STARTTLS", origin: context.logger_origin, verbosity: 5, type: :warn

          return
        end

        response = SMTP::Response.new(
          status: :positive_completed,
          category: :connections,
          message: "Ready to start TLS"
        )

        context.send_response(response)

        begin
          ssl_context = context.starttls_certificate
          ssl_socket = OpenSSL::SSL::SSLSocket.new(context.tcp_client, ssl_context)
          ssl_socket.sync_close = true
          ssl_socket.accept

          context.client = ssl_socket

          context.using_starttls = true

          Logger.log "Upgraded to TLS", origin: context.logger_origin, verbosity: 5
        rescue OpenSSL::SSL::SSLError
          Logger.log "Failed upgrading to TLS", origin: context.logger_origin, verbosity: 5, type: :warn
        end
      end
    end
  end
end
