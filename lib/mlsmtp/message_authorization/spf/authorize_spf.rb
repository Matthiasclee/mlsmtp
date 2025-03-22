module SMTPServer
  module MessageAuthorization
    module SPFAuthenticator
      def self.authorize_spf(context, config)
        Logger.log "Attempting SPF authorization", origin: context.logger_origin, verbosity: 5

        spf_server = SPF::Server.new

        request = SPF::Request.new(
          versions: config["versions"],
          scope: "mfrom",
          identity: Transport::Destination.new(context.mailfrom, get_servers: false).address,
          helo_identity: context.heloname
        )

        result = spf_server.process(request)

        result_code = result.code

        Logger.log "SPF result: #{result}", origin: context.logger_origin, verbosity: 5

        context.additional_authorization_data[:spf_result] = result_code

        return config["ok_results"].include?(result_code.to_s)
      end
    end
  end
end
