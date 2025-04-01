module SMTPServer
  module Authentication
    class NoneAdapter
      def initialize(conf)
      end
      
      def authenticate(user, password)
        false
      end
    end
  end
end
