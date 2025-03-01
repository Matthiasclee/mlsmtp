module SMTPServer
  module SMTP
    class SMTPClientContext
      def initialize(client)
        @client = client
        @current_status = :new
      end
    end
  end
end
