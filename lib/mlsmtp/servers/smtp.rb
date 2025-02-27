module SMTPServer
  module Servers
    class SMTPServer
      def initialize(starttls:) # :off, :optional, :force
        @server = TCPServer.new()
      end
    end
  end
end
