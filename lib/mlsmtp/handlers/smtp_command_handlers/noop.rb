module SMTPServer
  module Handlers
    module SMTPCommandHandlers
      def self.noop(context)
        response = SMTP::Response.new(
          status: :positive_completed,
          category: :mail_system,
          detail: 0,
          message: "2.0.0 Ok"
        )
        context.send_response(response)
      end
    end
  end
end
