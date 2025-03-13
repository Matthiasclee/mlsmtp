module SMTPServer
  module Handlers
    module SMTPCommandHandlers
      def self.auth(context, args)
        auth_methods = Config.active["authentication"]["valid_auth_methods"]

        unless auth_methods.include?(args[0].upcase)
          response = SMTP::Response.new(
            status: :negative_permanent,
            category: :authentication,
            detail: 5,
            message: "5.7.8 Invalid Mechanism"
          )
          context.send_response(response)

          Logger.log "Client requested bad authentication mechanism #{args[0].upcase}", origin: context.logger_origin, verbosity: 5, type: :warn
          return
        end

        case args[0].upcase
        when "LOGIN"
          Authentication.method_login_handler(context)
        end
      end
    end
  end
end
