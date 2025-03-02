module SMTPServer
  module Handlers
    module SMTPCommandHandlers
      def self.mailfrom(context, args)
        unless @context.mailfrom
          message = SMTP::Response.new(
            status: :negative_permanent,
            category: :syntax,
            detail: 3,
            message: "Error: HELO/EHLO required"
          )
          @context.send_response(message)
          return
        end

        if @context.mailfrom != :ready
          message = SMTP::Response.new(
            status: :negative_permanent,
            category: :syntax,
            detail: 3,
            message: "Error: repeated MAIL FROM: command"
          )
          @context.send_response(message)
          return
        end

        message = SMTP::Response.new(
          status: :positive_completed,
          category: :mail_system,
          message: "Ok"
        )
        @context.send_response(message)

        @context.mailfrom = args[0]
        @context.rcptto = :ready
      end
    end
  end
end
