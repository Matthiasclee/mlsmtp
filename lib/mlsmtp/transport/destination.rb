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
        if domain.match?(/\[.*\]/)
          return [domain[1..-2]]
        end

        mx_records = Resolv::DNS.open do |dns|
            dns.getresources(domain, Resolv::DNS::Resource::IN::MX)
        end

        return mx_records.map{|x| [x.preference, x.exchange.to_s]}.sort_by(&:first).map(&:last)
      end
    end
  end
end
