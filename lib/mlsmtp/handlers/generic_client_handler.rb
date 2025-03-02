module SMTPServer
  module Handlers
    class GenericClientHandler
      def initialize(context)
        @context = context
      end

      def handle_client
        @context.send_banner unless @context.banner_sent

        until @context.closed
          raw_command = @context.read[0]
          begin
            command = SMTP::Command.parse(raw_command)
          rescue SMTPServer::Errors::InvalidCommandError => e
            response = SMTP::Response.new(
              status: :negative_permanent,
              category: :syntax,
              detail: 2,
              message: "Error: command not recognized"
            )
            @context.send_response(response)
            next
          rescue SMTPServer::Errors::IncompleteCommandError => e
            response = SMTP::Response.new(
              status: :negative_permanent,
              category: :syntax,
              detail: 1,
              message: "Syntax: #{e.template_command.map{|x| x == String ? "<argument>" : x}.join(" ")}"
            )
            @context.send_response(response)
            next
          end

          case command.command
          when [ "HELO" ]
            SMTPCommandHandlers.helo(@context, command.values)
          when [ "MAIL", "FROM:" ]
            SMTPCommandHandlers.mailfrom(@context, command.values)
          when [ "RCPT", "TO:" ]
            SMTPCommandHandlers.rcptto(@context, command.values)
          when [ "DATA" ]
            SMTPCommandHandlers.data(@context)
          when [ "QUIT" ]
            SMTPCommandHandlers.quit(@context)
          when [ "RSET" ]
          when [ "VRFY" ]
          when [ "EXPN" ]
          when [ "NOOP" ]
          end
        end
      end
    end
  end
end
