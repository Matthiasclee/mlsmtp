module SMTPServer
  module Handlers
    class GenericClientHandler
      def initialize(context, logger_origin="Client Handler")
        @context = context
        @logger_origin = "Handler: #{@context.ip_addr}"
      end

      def handle_client
        unless @context.banner_sent
          @context.send_banner 
          Logger.log "Sending banner to client", origin: @logger_origin, verbosity: 4
        end

        until @context.closed
          raw_command = @context.read[0]
          begin
            command = SMTP::Command.parse(raw_command)
          rescue SMTPServer::Errors::InvalidCommandError => e
            Logger.log "Invalid command from client: `#{e.command}`", type: :warn, origin: @logger_origin, verbosity: 4
            response = SMTP::Response.new(
              status: :negative_permanent,
              category: :syntax,
              detail: 2,
              message: "Error: command not recognized"
            )
            @context.send_response(response)
            next
          rescue SMTPServer::Errors::IncompleteCommandError => e
            Logger.log "Incomplete command from client: `#{e.original_command}`", type: :warn, origin: @logger_origin, verbosity: 4
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
            Logger.log "Received MAIL FROM: command from client", origin: @logger_origin, verbosity: 4
            SMTPCommandHandlers.mailfrom(@context, command.values)
          when [ "RCPT", "TO:" ]
            Logger.log "Received RCPT TO: command from client", origin: @logger_origin, verbosity: 4
            SMTPCommandHandlers.rcptto(@context, command.values)
          when [ "DATA" ]
            Logger.log "Received DATA command from client", origin: @logger_origin, verbosity: 4
            SMTPCommandHandlers.data(@context)
          when [ "QUIT" ]
            Logger.log "Received QUIT command from client", origin: @logger_origin, verbosity: 4
            SMTPCommandHandlers.quit(@context)
          when [ "RSET" ]
            Logger.log "Received RSET command from client", origin: @logger_origin, verbosity: 4
            SMTPCommandHandlers.rset(@context)
          when [ "VRFY" ]
            Logger.log "Received VRFY command from client", origin: @logger_origin, verbosity: 4
          when [ "EXPN" ]
            Logger.log "Received EXPN command from client", origin: @logger_origin, verbosity: 4
          when [ "NOOP" ]
            Logger.log "Received NOOP command from client", origin: @logger_origin, verbosity: 4
            SMTPCommandHandlers.noop(@context)
          end
        end
      end
    end
  end
end
