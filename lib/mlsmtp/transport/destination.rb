module SMTPServer
  module Transport
    class Destination
      def initialize(address)
        @address = fix_address(address)
        @destination = Rules.active.determine_destination(@address)
        @destination_user = @destination[0]

        if @destination[1]
          @destination_servers = get_destination_servers(@destination[1])
        else
          @local = true
        end
      end

      attr_reader :address, :destination, :destination_user, :destination_servers, :local

      private
      
      def get_destination_servers(destination)
        dest_servers = []

        if !(destination[:server_addrs].to_a.empty?)
          dest_servers = destination[:server_addrs]
        elsif destination[:mail_domain]
          dest_servers = get_mx_records(destination[:mail_domain])
        end

        return dest_servers
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

      def fix_address(address)
        if address.match?(/^\<.*\>$/)
          inner_address = address[1..-2]
        elsif address.split(?<)[-1].match?(/^.*\>$/)
          inner_address = address.split(?<)[-1][0..-2]
        else
          inner_address = address
        end

        if address.split(?@).length == 1
          return "#{inner_address}@0.0.0.0"
        else
          return inner_address
        end
      end
    end
  end
end
