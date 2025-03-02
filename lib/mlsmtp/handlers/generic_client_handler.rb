module SMTPServer
  module Handlers
    class GenericClientHandler
      def initialize(context)
        @context = context
      end

      def handle_client
        @context.send_banner unless @context.banner_sent

        until @context.closed
          if @context.data == :ready
          else
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
              SMTPCommandHandlers.helo(@context, command.command)
            when [ "MAIL", "FROM:" ]
            when [ "RCPT", "TO:" ]
            when [ "DATA" ]
            when [ "QUIT" ]
            when [ "RSET" ]
            when [ "VRFY" ]
            when [ "NOOP" ]
            end
          end
        end
      end
    end
  end
end
