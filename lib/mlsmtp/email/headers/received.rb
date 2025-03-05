module SMTPServer
  module Email
    module Headers
      class Received
        def initialize(context)
          @received_helo = context.heloname
          @received_ip = context.ip_addr

          @recipient_host = Config["mailname"]
        end
        
        def to_s
          "from #{@received_helo} ()"
        end
      end
    end
  end
end
