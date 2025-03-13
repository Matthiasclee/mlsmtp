module SMTPServer
  module Authentication
    class PAMAdapter
      def initialize(conf)
        @override_service = conf["override_service"]
      end

      def authenticate(user, password)
        if @override_service
          return Rpam.auth(user, password, service: @override_service)
        else
          return Rpam.auth(user, password)
        end
      end
    end
  end
end
