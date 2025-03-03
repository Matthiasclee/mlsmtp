module SMTPServer
  module Transport
    class Destination
      def initialize(address)
        @address = address
        @destination = Rules.active.determine_destination(@address)
        @destination_user = @destination[0]
        @destination_servers = get_destination_domains(@destination[1])
      end

      private
      
      def get_destination_servers(destination)
        dest_servers = []

        dest_server += destination[:server_addrs].to_a
        if destination[:mail_domain]
          dest_servers += get_mx_records(destination[:mail_domain])
        end
      end

      def get_mx_records(domain)

      end
    end
  end
end
