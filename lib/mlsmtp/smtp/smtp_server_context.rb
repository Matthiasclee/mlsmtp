module SMTPServer
  module SMTP
    class SMTPServerContext
      def initialize(server)
        @server = server
        @ready_for = :helo
        @recipient_addr = nil
        @sender_addr = nil
        @data = nil

        @ip_addr = @server.peeraddr[3]
        @logger_origin = "Server Handler: #{@ip_addr}"
      end

      def send_data(response)
        response = response.to_s if response.is_a?(Command)
        response = [ response ] unless response.is_a?(Array)

        response.each do |line|
          @server.print "#{line}\r\n"
        end
      end

      def read_response
        response_lines = []

        while true
          response_lines << @server.gets.chomp
          response = Response.parse(response_lines)
          return response unless response == :incomplete
        end
      end

      def close
        @server.close
      end

      attr_reader :ip_addr, :logger_origin
      attr_accessor :ready_for, :recipient_addr, :sender_addr, :data
    end
  end
end
