module SMTPServer
  module Transport
    class RemoteDeliveryAgent
      def initialize(destination:, sender:,  message:, origin:)
        @message = message
        @destination = destination
        @servers = @destination.destination_servers
        @recipient_addr = @destination.destination_user
        @sender_addr = sender
        @origin = origin
      end

      def attempt_delivery
        port = 25

        @servers.each do |server|
          break if deliver_to_server(server, port)
        end
      end

      attr_accessor :message, :destination, :servers, :recipient_addr

      private

      def deliver_to_server(server, port)
        Logger.log "Trying server #{server}:#{port}", origin: @origin, verbosity: 3
        server = TCPSocket.new(server, port)

        Logger.log "Creating context for server", origin: @origin, verbosity: 3
        context = SMTP::SMTPServerContext.new(server)
        context.recipient_addr = @recipient_addr
        context.sender_addr = @sender_addr
        context.data = @message

        Logger.log "Handling server", origin: @origin, verbosity: 3
        handler = Handlers::SMTPServerHandler.new(context)
        return handler.handle_client(context)
      end
    end
  end
end
