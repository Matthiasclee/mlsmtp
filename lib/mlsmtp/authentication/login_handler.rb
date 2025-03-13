module SMTPServer
  module Authentication
    def self.method_login_handler(context)
      Logger.log "Trying auth LOGIN", origin: context.logger_origin, verbosity: 5

      username_request = SMTP::Response.new(
        status: :positive_intermediate,
        category: :authentication,
        detail: 4,
        message: "VXNlcm5hbWU6"
      )
      context.send_response(username_request)
      username = Base64.decode64(context.read[0])

      Logger.log "Client username: #{username}", origin: context.logger_origin, verbosity: 5

      password_request = SMTP::Response.new(
        status: :positive_intermediate,
        category: :authentication,
        detail: 4,
        message: "UGFzc3dvcmQ6"
      )
      context.send_response(password_request)
      password = Base64.decode64(context.read[0])

      Logger.log "Client password: #{password}", origin: context.logger_origin, verbosity: 5

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
