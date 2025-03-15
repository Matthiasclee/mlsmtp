module SMTPServer
  module Handlers
    module SMTPCommandHandlers
      def self.data(context)
        unless context.data == :ready
          Logger.log "Received unexpected DATA command", origin: context.logger_origin, verbosity: 5, type: :warn

          message = SMTP::Response.new(
            status: :negative_permanent,
            category: :syntax,
            detail: 3,
            message: "5.5.1 Error: MAIL FROM: required"
          )
          context.send_response(message)
          return
        end

        Logger.log "Received DATA command, waiting for message", origin: context.logger_origin, verbosity: 5

        message = SMTP::Response.new(
          status: :positive_intermediate,
          category: :mail_system,
          detail: 4,
          message: "End data with <CRLF>.<CRLF>"
        )
        context.send_response(message)

        data = context.read(read_until: ".").map{ |l| l[0] == ?. ? l[1..-1] : l }.join("\r\n")

        if data.length > Config.active["max_size"]
          message = SMTP::Response.new(
            status: :negative_permanent,
            category: :mail_system,
            detail: 2,
            message: "5.3.4 Message exceeds max size"
          )
          context.send_response(message)

          Logger.log "Message exceeds max size", origin: context.logger_origin, verbosity: 5, type: :warn
          return
        end

        context.data = data

        queue_ids = []

        preparer = Email::EmailPreparer.new(context)
        preparer.add_all_headers

        i = 0
        while i < context.rcptto.length
          rcpt_to = context.rcptto[i]
          i += 1

          fixed_address = Transport::Destination.new(rcpt_to, get_servers: false).address

          mail_list = MailLists::MailList.find_by_name(fixed_address)

          if mail_list
            context.rcptto.delete(rcpt_to)
            context.rcptto += mail_list.expand
            i -= 1
            next
          end

          message = Queue::QueuedMessage.new(
            mail_from: context.mailfrom,
            rcpt_to: rcpt_to,
            message: preparer.to_s
          )

          queue_ids << message.queue[1]
        end

        message = SMTP::Response.new(
          status: :positive_completed,
          category: :mail_system,
          message: Config.active["queue"]["return_queue_ids"] ? "2.0.0 Message queued as #{queue_ids.join(?,)}" : "2.0.0 Message queued"
        )
        context.send_response(message)

        context.reset

        Logger.log "Queued message as #{queue_ids.join(?,)}", origin: context.logger_origin, verbosity: 5
      end
    end
  end
end
