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
            return [ destination.gsub("%u", user).gsub("%d", domain), :local ]
          end
        end

        return [ user, domain ]
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
    end
  end
end
