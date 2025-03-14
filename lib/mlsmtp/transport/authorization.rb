module SMTPServer
  module Transport
    class Authorization
      @@active_authorization = nil

      def initialize(authorization_file)
        @file = authorization_file
        @authorization = JSON.parse(File.read(@file))
      end

      def authorized?(context:, destination:)
        destination_address = destination.address
        sender_address = context.mailfrom
      end

      def set_active
        @@active_authorization = self
      end

      def self.active
        @@active_authorization
      end

      def self.clear_active
        @@active_authorization = @@default_authorization
      end

      @@default_authorization = new(Config.active["transport_authorization_file"])
      @@default_authorization.set_active

      attr_accessor :file, :authorization

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
