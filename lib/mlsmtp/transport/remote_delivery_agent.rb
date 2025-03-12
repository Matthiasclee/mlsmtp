module SMTPServer
  module Transport
    class RemoteDeliveryAgent
      @@attempt_ports = Config.active["external_transport"]["attempt_ports"]
      @@timeout = Config.active["external_transport"]["socket_timeout"]

      def initialize(destination:, sender:,  message:, origin:)
        @message = message
        @destination = destination
        @servers = @destination.destination_servers
        @recipient_addr = @destination.destination_user
        @sender_addr = sender
        @origin = origin
      end

      def attempt_delivery
        @@attempt_ports.each do |port|
          @servers.each do |server|
            return true if deliver_to_server(server, port)
          end
        end

        raise Errors::ServerRejectionError
      end

      attr_accessor :message, :destination, :servers, :recipient_addr

      private

      def deliver_to_server(server, port)
        Logger.log "Trying server #{server}:#{port}", origin: @origin, verbosity: 3
        tcp_server = nil

        begin
          Timeout.timeout(@@timeout) do
            tcp_server = TCPSocket.new(server, port)
          end
        rescue Errno::ECONNREFUSED
          Logger.log "Connection to #{server}:#{port} refused", origin: @origin, verbosity: 3, type: :warn
          return false
        rescue Timeout::Error
          Logger.log "#{server}:#{port} timed out in #{@@timeout} seconds", origin: @origin, verbosity: 3, type: :warn
          return false
        end

        Logger.log "Creating context for server", origin: @origin, verbosity: 3
        context = SMTP::SMTPServerContext.new(tcp_server)
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
