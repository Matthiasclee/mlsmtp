module SMTPServer
  module Handlers
    module SMTPCommandHandlers
      def self.rset(context)
        context.reset

        response = SMTP::Response.new(
          status: :positive_completed,
          category: :mail_system,
          detail: 0,
          message: "Ok"
        )
        context.send_response(response)
      end
    end
  end
end
