module SMTPServer
  module Handlers
    module SMTPCommandHandlers
      def self.auth(context, args)
        auth_methods = Config.active["authentication"]["valid_auth_methods"].keys

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

        auth_const, auth_method = Config.active["authentication"]["valid_auth_methods"][args[0].upcase]

        Object.const_get(auth_const).method(auth_method).call(context)
      end
    end
  end
end
