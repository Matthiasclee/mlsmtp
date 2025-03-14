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
        destination_user, destination_domain = destination_address.split(?@)

        sender_address = context.mailfrom
        sender_ip = IPAddr.new(context.ip_addr)
        authenticated_as = context.authenticated_as

        @authorization.each do |auth_rule|
          rule_type = auth_rule["rule_type"].to_s.downcase

          raise Errors::BadAuthRuleError, rule_type unless [ "allow", "deny" ].include?(rule_type)

          match_conditions = auth_rule["match_by"]
          determine_conditions = auth_rule["determine_by"]

          next unless matches?(
            match_conditions,
            destination_user: destination_user,
            destination_domain: destination_domain,
            destination_address: destination_address,
            sender_address: sender_address,
            sender_ip: sender_ip
          )

          result = matches?(
            determine_conditions,
            destination_user: destination_user,
            destination_domain: destination_domain,
            destination_address: destination_address,
            sender_address: sender_address,
            sender_ip: sender_ip
          )

          result = !result if rule_type == "deny"

          return result
        end
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

      def matches?(auth_rule, destination_user:, destination_domain:, destination_address:, sender_address:, sender_ip:)
        allowed_sender_ips = auth_rule["from_ip"]

        from_email_re = Regexp.new(auth_rule["from_email"])
        to_email_re = Regexp.new(auth_rule["to_email"])

        sender_matches = sender_address ? sender_address.match?(from_email_re) : true
        recipient_matches = destination_address ? destination_address.match?(to_email_re) : true

        required_auth = substitute_specials(
          auth_rule["auth"],
          user: destination_user,
          domain: destination_domain,
          address: destination_address
        )

        if allowed_sender_ips
          ip_matches = allowed_sender_ips.any? do |ip|
            IPAddr.new(ip).include?(sender_ip)
          end
        else
          ip_matches = true
        end

        auth_matches = required_auth.nil? ? true : required_auth == authenticated_as || ( required_auth == false && authenticated_as == nil )

        return sender_matches && recipient_matches && ip_matches && auth_matches
      end
    end
  end
end
