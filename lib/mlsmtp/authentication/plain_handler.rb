module SMTPServer
  module Authentication
    def self.method_plain_handler(context, encoded_credentials)
      Logger.log "Trying auth PLAIN", origin: context.logger_origin, verbosity: 5

      unless encoded_credentials
        username_request = SMTP::Response.new(
          status: :positive_intermediate,
          category: :authentication,
          detail: 4
        )
        context.send_response(username_request)

        encoded_credentials = context.read[0]
      else
        encoded_credentials = encoded_credentials[0]
      end

      _, username, password = Base64.decode64(encoded_credentials).split("\0")

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
