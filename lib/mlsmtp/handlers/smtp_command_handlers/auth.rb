module SMTPServer
  module Handlers
    module SMTPCommandHandlers
      def self.auth(context, args)
        case args[0].upcase
        when "LOGIN"
          Authentication.method_login_handler(context)
        else
          response = SMTP::Response.new(
            status: :negative_permanent,
            category: :authentication,
            detail: 5,
            message: "5.7.8 Invalid Mechanism"
          )
          context.send_response(response)

          Logger.log "Client requested bad authentication mechanism #{args[0].upcase}", origin: context.logger_origin, verbosity: 5, type: :warn
        end
      end
    end
  end
end
