module SMTPServer
  module Email
    module Headers
      class Received
        def initialize(context)
          @received_helo = context.heloname
          @received_ip = context.ip_addr
        end
        
        def to_s
          "from #{@received_helo} (#{@received_helo} [#{@received_ip}]) " +
          "by #{Config.active["mailname"]} (#{Config.active["banner"]["banner_server_name"]}) " +
          "with ESMTP " +
          "#{Time.now.strftime("%a, %d %b %Y %H:%M:%S %z")}"
        end
      end
    end
  end
end
