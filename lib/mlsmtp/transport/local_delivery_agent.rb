module SMTPServer
  module Transport
    class LocalDeliveryAgent
      def initialize(user:, message:)
        @user = user
        @message = message
      end

      def attempt_delivery
        Storage::Active.add_message(@user, @message)
      end

      attr_reader :user, :message
    end
  end
end
