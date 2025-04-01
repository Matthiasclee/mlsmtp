module SMTPServer
  module Transport
    class Authorization
      @@active_authorization = nil

      def initialize(authorization_file)
        @file = authorization_file
        @authorization = JSON.parse(File.read(@file))
      end

      def authorized?(context)
        sender_address = Destination.new(context.mailfrom, get_servers: false).address
        sender_user, sender_domain = sender_address.split(?@)

        sender_ip = IPAddr.new(context.ip_addr)
        authenticated_as = context.authenticated_as

        context.rcptto.each do |recipient|
          destination = Destination.new(recipient, get_servers: false)

          destination_address = destination.address
          destination_user, destination_domain = destination_address.split(?@)

          @authorization.each do |auth_rule|
            rule_type = auth_rule["rule"].to_s.downcase
            auth_exempt = auth_rule["auth_exempt"] || false

            raise Errors::BadAuthRuleError, rule_type unless [ "allow", "deny" ].include?(rule_type)

            match_conditions = auth_rule["match_by"]
            determine_conditions = auth_rule["determine_by"]

            next unless matches?(
              match_conditions,
              destination_user: destination_user,
              destination_domain: destination_domain,
              destination_address: destination_address,
              sender_user: sender_user,
              sender_domain: sender_domain,
              sender_address: sender_address,
              sender_ip: sender_ip,
              authenticated_as: authenticated_as
            )

            result = matches?(
              determine_conditions,
              destination_user: destination_user,
              destination_domain: destination_domain,
              destination_address: destination_address,
              sender_user: sender_user,
              sender_domain: sender_domain,
              sender_address: sender_address,
              sender_ip: sender_ip,
              authenticated_as: authenticated_as
            )

            result = !result if rule_type == "deny"

            context.authorization_exempt = auth_exempt

            return result
          end
        end

        return false
      end

      def set_active
        @@active_authorization = self
      end

      def self.active
        @@active_authorization
      end

      def self.clear_active
        @@active_authorization = nil
      end

      attr_accessor :file, :authorization

      private

      def substitute_specials(string, user:, domain:, address:)
        string
          .gsub("%u", user)
          .gsub("%d", domain)
          .gsub("%a", address)
      end

      def matches?(auth_rule, destination_user:, destination_domain:, destination_address:, sender_user:, sender_domain:, sender_address:, sender_ip:, authenticated_as:)
        allowed_sender_ips = auth_rule["from_ip"]

        from_email_re = auth_rule["from_email"] ?  Regexp.new(auth_rule["from_email"]) : nil
        to_email_re = auth_rule["to_email"] ?  Regexp.new(auth_rule["to_email"]) : nil

        sender_matches = from_email_re ? sender_address.match?(from_email_re) : true
        recipient_matches = to_email_re ? destination_address.match?(to_email_re) : true

        if auth_rule["auth"].nil?
          auth_matches = true
        elsif auth_rule["auth"] == false
          auth_matches = authenticated_as == false
        else
          required_auth = substitute_specials(
            auth_rule["auth"],
            user: sender_user,
            domain: sender_domain,
            address: sender_address
          )
          auth_matches = required_auth == authenticated_as
        end

        if allowed_sender_ips
          ip_matches = allowed_sender_ips.any? do |ip|
            IPAddr.new(ip).include?(sender_ip)
          end
        else
          ip_matches = true
        end

        return sender_matches && recipient_matches && ip_matches && auth_matches
      end
    end
  end
end
