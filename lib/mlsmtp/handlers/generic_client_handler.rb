module SMTPServer
  module Handlers
    class GenericClientHandler
      def initialize(context)
        @context = context
      end

      def handle_client
        unless @context.banner_sent
          @context.send_banner 
          Logger.log "Sending banner to client", origin: @context.logger_origin, verbosity: 4
        end

        until @context.closed
          raw_command = @context.read[0]
          begin
            command = SMTP::Command.parse(raw_command)
          rescue SMTPServer::Errors::InvalidCommandError => e
            Logger.log "Invalid command from client: `#{e.command}`", type: :warn, origin: @context.logger_origin, verbosity: 4
            response = SMTP::Response.new(
              status: :negative_permanent,
              category: :syntax,
              detail: 2,
              message: "Error: command not recognized"
            )
            @context.send_response(response)
            next
          rescue SMTPServer::Errors::IncompleteCommandError => e
            Logger.log "Incomplete command from client: `#{e.original_command}`", type: :warn, origin: @context.logger_origin, verbosity: 4
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
            SMTPCommandHandlers.rset(@context)
          when [ "VRFY" ]
            SMTPCommandHandlers.vrfy(@context, command.values)
          when [ "EXPN" ]
          when [ "NOOP" ]
            SMTPCommandHandlers.noop(@context)
          end
        end
      end
    end
  end
end
