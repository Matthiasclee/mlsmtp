module SMTPServer
  module Transport
    class RemoteDeliveryAgent
      def initialize(destination:, message:, origin:)
        @message = message
        @destination = destination
        @servers = @destination.destination_servers
        @recipient_addr = @destination.destination_user
        @origin = origin
      end

      def attempt_delivery
        @servers.each do |server|
          deliver_to_server(server, port)
        end
      end

      attr_accessor :message, :destination, :servers, :recipient_addr

      private

      def deliver_to_server(server, port)
        Logger.log "Connecting to server #{server}:#{port}", origin: @origin, verbosity: 3
        server = TCPSocket.new(server, port)

        Logger.log "Creating context for server", origin: @origin, verbosity: 3
        context = SMTPServerContext.new(server)

        Logger.log "Handling server", origin: @origin, verbosity: 3
      end
    end
  end
end
