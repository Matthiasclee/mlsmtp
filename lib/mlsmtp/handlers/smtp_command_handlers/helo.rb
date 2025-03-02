module SMTPServer
  module Handlers
    module SMTPCommandHandlers
      def self.helo(context, args)
        context.heloname = args[0]
        context.mailfrom = :ready unless context.mailfrom

        response = SMTP::Response.new(
          status: :positive_completed,
          category: :mail_system,
          message: Config.active["mailname"]
        )

        context.send_response(response)
      end
    end
  end
end
