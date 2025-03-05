module SMTPServer
  module Handlers
    module SMTPCommandHandlers
      def self.data(context)
        unless context.data == :ready
          message = SMTP::Response.new(
            status: :negative_permanent,
            category: :syntax,
            detail: 3,
            message: "Error: MAIL FROM: required"
          )
          context.send_response(message)
          return
        end

        message = SMTP::Response.new(
          status: :positive_intermediate,
          category: :mail_system,
          detail: 4,
          message: "End data with <CRLF>.<CRLF>"
        )
        context.send_response(message)

        data = context.read(read_until: ".").map{|l| l[1..-1] if l[0] == ?.}

        context.data = data

        queue_ids = []

        context.rcptto.each do |rcpt_to|
          message = Queue::QueuedMessage.new(
            mail_from: context.mailfrom,
            rcpt_to: rcpt_to
            message: data
          )

          queue_ids << message.queue[1]
        end

        message = SMTP::Response.new(
          status: :positive_completed,
          category: :mail_system,
          message: Config.active["queue"]["return_queue_ids"] ? "Message queued as #{queue_ids.join(?,)}" "Message queued"
        )
        context.send_response(message)

        context.reset
      end
    end
  end
end
