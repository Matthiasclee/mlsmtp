module SMTPServer
  module Transport
    class AuthorizationHandler
      def initialize(context)
        @context = context
      end

      def handle_authorization
        authorized = Authorization.active.authorized?(@context)

        if authorized
          Logger.log "Authorization passed", origin: @context.logger_origin, verbosity: 5
          @context.data = :ready
        else
          Logger.log "Authorization failed", origin: @context.logger_origin, verbosity: 5, type: :warn
          response = SMTP::Response.new(
            status: :negative_permanent,
            category: :mail_system,
            detail: 3,
            message: "5.7.1 Authorization Error"
          )

          @context.send_response(response)
        end
      end
    end
  end
end
