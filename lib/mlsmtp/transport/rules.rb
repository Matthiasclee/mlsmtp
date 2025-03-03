module SMTPServer
  module Transport
    class Rules
      @@active_rules = nil

      def initialize(rules_file)
        @file = rules_file
        @rules = JSON.parse(File.read(@file))
      end

      def determine_destination(address)
        user, domain = address.split(?@, 2)
        @rules.each do |rule|
          regex, destination = rule

          if address.match?(Regexp.new(regex))
            dest_user = substitute_specials(
              destination[0],
              user: user,
              domain: domain,
              address: address
            )

            if destination[1]
              dest_server = {server_addrs: destination[1]}
            else
              dest_server = nil
            end

            return [ dest_user, dest_server ]
          end
        end

        return [ address, {mail_domain: domain} ]
      end

      def set_active
        @@active_rules = self
      end

      def self.active
        @@active_rules
      end

      def self.clear_active
        @@active_rules = @@default_rules
      end

      @@default_rules = new(Config.active["transport_rules_file"])
      @@default_rules.set_active

      attr_accessor :file, :rules

      private

      def substitute_specials(string, user:, domain:, address:)
        string
          .gsub("%u", user)
          .gsub("%d", domain)
          .gsub("%a", address)
      end
    end
  end
end
