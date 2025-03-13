module SMTPServer
  module Authentication
    def self.method_plain_handler(context)
      Logger.log "Trying auth LOGIN", origin: context.logger_origin, verbosity: 5

      username_request = SMTP::Response.new(
        status: :positive_intermediate,
        category: :authentication,
        detail: 4
      )
      context.send_response(username_request)
      _, username, password = Base64.decode64(context.read[0]).split("\0")

      Logger.log "Client credentials received: #{username}:***", origin: context.logger_origin, verbosity: 5

      if Active.authenticate(username, password)
        response = SMTP::Response.new(
          status: :positive_completed,
          category: :authentication,
          detail: 5,
          message: "2.7.0 Authentication Successful"
        )

        context.authenticated_as = username

        Logger.log "Authenticated successfully", origin: context.logger_origin, verbosity: 5
      else
        response = SMTP::Response.new(
          status: :negative_permanent,
          category: :authentication,
          detail: 5,
          message: "5.7.8 Authentication Failed"
        )

        Logger.log "Authentication failed", origin: context.logger_origin, verbosity: 5, type: :warn
      end

      context.send_response(response)
    end
  end
end
