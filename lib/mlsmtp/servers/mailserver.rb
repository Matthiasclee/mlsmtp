module SMTPServer
  module Servers
    class MailServer
      @@all_servers = []
      @@running_servers = []

      def initialize(host:, port:, encryption:)
        @host = host
        @port = port
        @running = false
        @dead = false
        @pid = nil

        @@all_servers << self
      end

      def start
        return false if @dead
        return true if @running

        @running = true
        @@running_servers << self

        @pid = fork do
          Database.connect
          server = TCPServer.new(@host, @port)

          while @running
            Thread.start(server.accept) do |client|
              context = SMTP::SMTPClientContext.new(client)
              handler = Handlers::GenericClientHandler.new(context)

              handler.handle_client
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
      end

      def kill
        stop
        @dead = true
        @@all_servers.delete(self)
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
