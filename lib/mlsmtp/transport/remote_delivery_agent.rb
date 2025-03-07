module SMTPServer
  module Transport
    class RemoteDeliveryAgent
      def initialize(destination:, message:)
        @message = message
        @destination = destination
        @servers = @destination.destination_servers
        @recipient_addr = @destination.destination_user
      end

      def attempt_delivery
        @servers.each do |server|
          deliver_to_server(server)
        end
      end

      attr_accessor :message, :destination, :servers, :recipient_addr

      private

      def deliver_to_server(server)
        server = TCPSocket.new(server, 25)
      end
    end
  end
end
