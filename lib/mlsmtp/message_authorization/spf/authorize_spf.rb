module SMTPServer
  module MessageAuthorization
    module SPFAuthenticator
      def self.authorize_spf(context, config)
        Logger.log "Attempting SPF authorization", origin: context.logger_origin, verbosity: 5

        spf_server = SPF::Server.new

        begin
          request = SPF::Request.new(
            versions: config["versions"],
            scope: "mfrom",
            identity: Transport::Destination.new(context.mailfrom, get_servers: false).address,
            ip_address: context.ip_addr,
            helo_identity: context.heloname
          )

          result = spf_server.process(request)

          result_code = result.code.to_s
        rescue
          result_code = config["on_spf_fail"]
        end

        Logger.log "SPF result: #{result_code}", origin: context.logger_origin, verbosity: 5

        context.additional_authorization_data[:spf_result] = result_code

        return config["ok_results"].include?(result_code)
      end
    end
  end
end
