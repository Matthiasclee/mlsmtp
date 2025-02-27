module SMTPServer
  module Servers
    class SubmissionServer
      def initialize(host:, port:, encryption:) # :st_off, :st_optional, :st_force, :tls
        @server = TCPServer.new(host, port)
      end
    end
  end
end
