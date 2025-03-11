module SMTPServer
  module Handlers
    module SMTPCommandHandlers
      def self.ehlo(context, args)
        context.heloname = args[0]
        context.esmtp = true
        context.mailfrom = :ready unless context.mailfrom

        esmtp_message = [
          Config.active["mailname"],
          "SIZE #{Config.active["max_size"]}",
          "PIPELINING",
        ]
        esmtp_message += [ "8BITMIME", "SMTPUTF8" ] if Config.active["support_8_bit"]
        esmtp_message << "VRFY" unless Config.active["disable_commands"].include?("VRFY")
        esmtp_message << "STARTTLS" if context.starttls_support

        response = SMTP::Response.new(
          status: :positive_completed,
          category: :mail_system,
          message: esmtp_message
        )

        context.send_response(response)

        Logger.log "Client EHLO: #{context.heloname}", origin: context.logger_origin, verbosity: 5
      end
    end
  end
end
