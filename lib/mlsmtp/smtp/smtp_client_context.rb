module SMTPServer
  module SMTP
    class SMTPClientContext
      def initialize(client)
        @client = client
        @current_status = :new_connection
      end

      def send_banner
        banner = Banner.new.to_response
        send_response(banner)

        @current_status = :done
      end

      attr_accessor :current_status

      private
      
      def send_response(response)
        response = response.split("\r\n") if response.is_a?(String)
        response = response.to_a if response.is_a?(Response)

        response.each do |rline|
          @client.print "#{rline}\r\n"
        end
      end
    end
  end
end
