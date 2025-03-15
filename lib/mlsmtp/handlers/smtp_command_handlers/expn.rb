module SMTPServer
  module Handlers
    module SMTPCommandHandlers
      def self.expn(context, args)
        list = Transport::Destination.new(args[0], get_servers: false).address

        list_members = MailLists::MailList.find_by_name(list)&.expand

        if list_members.nil? || list_members.empty?
          response = SMTP::Response.new(
            status: :negative_permanent,
            category: :mail_system,
            message: "Mailing list is empty or does not exist"
          )

          Logger.log "Requested email list `#{list}` is empty or does not exist", origin: context.logger_origin, verbosity: 5, type: :warn
        else
          response = SMTP::Response.new(
            status: :positive_completed,
            category: :mail_system,
            message: list_members.map{|m| "<#{m}>"}
          )

          Logger.log "Returned #{list_members.length} members of list #{list}", origin: context.logger_origin, verbosity: 5
        end

        context.send_response(response)
      end
    end
  end
end
