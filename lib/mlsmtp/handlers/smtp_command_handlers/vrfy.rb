module SMTPServer
  module Handlers
    module SMTPCommandHandlers
      def self.vrfy(context, args)
        email = args[0]

        destination = Transport::Destination.new(email)

        if destination.local && Storage::Active.mailbox_exists?(destination.destination_user)
          response = SMTP::Response.new(
            status: :positive_completed,
            category: :mail_system,
            message: email
          )

          Logger.log "Requested address `#{email}` exists on this server", origin: context.logger_origin, verbosity: 5
        else
          response = SMTP::Response.new(
            status: :negative_permanent,
            category: :mail_system,
            message: "User does not exist"
          )

          Logger.log "Requested address `#{email}` does not exist on this server", origin: context.logger_origin, verbosity: 5
        end

        context.send_response(response)
      end
    end
  end
end
