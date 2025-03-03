module SMTPServer
  module Transport
    class Destination
      def initialize(address)
        @account, @domain = address.split(?@)
      end
    end
  end
end
