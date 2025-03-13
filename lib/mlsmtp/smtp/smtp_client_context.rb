module SMTPServer
  module SMTP
    class SMTPClientContext
      def initialize(client)
        @tcp_client = client
        @client = @tcp_client
        @banner_sent = false
        @closed = false
        @mailfrom = (Config.active["require_helo"] ? false : :ready)
        @ip_addr = @client.peeraddr[3]
        @logger_origin = "Client Handler: #{@ip_addr}"
        @use_8bit = Config.active["support_8_bit"] && Config.active["esmtp_enable"]
        @esmtp = false
        @starttls_support = false
        @using_starttls = false
        @starttls_certificate = nil

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

          unless @use_8bit
            line = line.encode('US-ASCII', invalid: :replace, undef: :replace, replace: '?')
          end

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

      attr_accessor :mailfrom, :rcptto, :data, :done, :closed, :banner_sent, :heloname, :ip_addr, :logger_origin, :esmtp, :starttls_support, :tcp_client, :client, :starttls_certificate, :using_starttls, :authenticated_as

      private

      def initialize_statuses
        @done = false
        @mailfrom = @mailfrom ? :ready : false
        @heloname = nil
        @rcptto = false
        @data = false
        @authenticated_as = nil
      end
    end
  end
end
