module SMTPServer
  module Errors
    class BadAuthRuleError < StandardError
      def initialize(auth_rule)
        @auth_rule = auth_rule
      end

      def to_s
        "Bad auth rule: #{@auth_rule}. Acceptable options are \"allow\", \"deny\""
      end

      attr_reader :auth_rule
    end
  end
end
