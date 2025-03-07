module SMTPServer
  module Errors
    class ServerRejectionError < StandardError
      def initialize
      end

      def to_s
        "All available servers rejected the message."
      end
    end
  end
end
