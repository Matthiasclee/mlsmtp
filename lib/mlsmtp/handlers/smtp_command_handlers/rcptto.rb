module SMTPServer
  module Handlers
    module SMTPCommandHandlers
      def self.rcptto(context, args)
        unless context.rcptto
          message = SMTP::Response.new(
            status: :negative_permanent,
            category: :syntax,
            detail: 3,
            message: "Error: MAIL FROM: required"
          )
          context.send_response(message)
          return
        end

        context.rcptto << args[0]

        message = SMTP::Response.new(
          status: :positive_completed,
          category: :mail_system,
          message: "Ok"
        )
        context.send_response(message)
      end
    end
  end
end
