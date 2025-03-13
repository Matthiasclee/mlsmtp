module SMTPServer
  module Authentication
    class DebugAdapter
      def initialize(conf)
        @good_credentials = conf["credentials"]
      end
      
      def authenticate(user, password)
        @good_credentials[user] == password && user && password
      end
    end
  end
end
