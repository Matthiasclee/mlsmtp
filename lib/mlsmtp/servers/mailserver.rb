module SMTPServer
  module Servers
    class MailServer
      @@all_servers = []
      @@running_servers = []

      def initialize(host:, port:, encryption:, certificate:)
        @host = host
        @port = port
        @running = false
        @dead = false
        @pid = nil
        @encryption = encryption
        @certificate = certificate

        obj_id = self.object_id
        @origin = "Server #{obj_id}"

        @@all_servers << self
      end

      def start
        return false if @dead
        return true if @running

        @running = true
        @@running_servers << self

        @pid = fork do
          begin
            Database.connect
            Logger.log "Successfully connected to database", origin: @origin, verbosity: 1
          rescue => e
            Logger.log "Error connecting to database", type: :error, origin: @origin
            raise e
          end

          tcp_server = TCPServer.new(@host, @port)
          
          if @encryption == :implicit
            context = @certificate.context
            server = OpenSSL::SSL::SSLServer.new(tcp_server, context)
          else
            server = tcp_server
          end

          Logger.log "Listening on #{@host}:#{@port}, encryption: #{@encryption}", origin: @origin, verbosity: 1

          while @running
            begin
              Thread.start(server.accept) do |client|
                client_ip = client.peeraddr[3]

                Logger.log "New connection from #{client_ip}", origin: @origin, verbosity: 2

                context = SMTP::SMTPClientContext.new(client)
                Logger.log "Creating SMTP client context for #{client_ip}", origin: @origin, verbosity: 3

                Logger.log "Handling client #{client_ip}", origin: @origin, verbosity: 3
                handler = Handlers::GenericClientHandler.new(context)
                handler.handle_client
              end
            rescue OpenSSL::SSL::SSLError
              Logger.log "SSL error for client", origin: @origin, verbosity: 2, type: :warn
            end
          end
        end

        return @pid
      end

      def restart
        stop
        sleep(Config.active["socket"]["restart_delay"])
        start
      end

      def stop(killcode: "TERM")
        Process.kill(killcode, @pid)
        @running = false
        @@running_servers.delete(self)

        Logger.log "Stopped server", origin: @origin, verbosity: 1
      end

      def kill
        stop
        @dead = true
        @@all_servers.delete(self)

        Logger.log "Killed server", origin: @origin, verbosity: 1
      end

      def self.all_servers
        @@all_servers
      end

      def self.running_servers
        @@running_servers
      end

      attr_reader :host, :port, :running, :dead, :pid
    end
  end
end
