module SMTPServer
  module SMTP
    class SMTPClientContext
      def initialize(client)
        @client = client
        @banner_sent = false
        @closed = false
        @mailfrom = (Config.active["require_helo"] ? false : :ready)
        @ip_addr = @client.peeraddr[3]
        @logger_origin = "Client Handler: #{@ip_addr}"

        initialize_statuses
      end

      def send_banner
        return false if @closed
        banner = Banner.new.to_response
        send_response(banner)

        @banner_sent = true
      end

      def send_response(response)
        return false if @closed
        response = response.split("\r\n") if response.is_a?(String)
        response = response.to_a if response.is_a?(Response)

        response.each do |rline|
          @client.print "#{rline}\r\n"
        end
      end

      def reset
        initialize_statuses
      end

      def close
        @closed = true
        @client.close
      end

      def read(read_until: nil)
        return false if @closed

        lines = []

        while true
          line = @client.gets
          if line
            line = line.chomp
          else
            @closed = true
            return [""]
          end

          break if line == read_until
          lines << line
          break unless read_until
        end

        return lines
      end

      attr_accessor :mailfrom, :rcptto, :data, :done, :closed, :banner_sent, :heloname, :ip_addr, :logger_origin

      private

      def initialize_statuses
        @done = false
        @mailfrom = @mailfrom ? :ready : false
        @heloname = nil
        @rcptto = false
        @data = false
      end
    end
  end
end
