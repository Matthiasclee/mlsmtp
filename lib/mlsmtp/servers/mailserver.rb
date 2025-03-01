module SMTPServer
  module Servers
    class MailServer
      @@all_servers = []
      @@running_servers = []

      def initialize(host:, port:, encryption:)
        @server = TCPServer.new(host, port)
        @host = host
        @port = port
        @running = false
        @dead = false
        @pid = nil

        @@all_servers << self
      end

      def start
        return false if @dead

        @running = true
        @@running_servers << self

        @pid = fork do
          while @running
            Thread.start(@server.accept) do |client|

            end
          end
        end

        return @pid
      end

      def restart
        stop
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
