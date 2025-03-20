module SMTPServer
  module MessageAuthorization
    class SPFHeader
      def initialize(context)
        @spf_result = context.additional_authorization_data[:spf_result]
        @client_ip = context.ip_addr
        @heloname = context.heloname
        @mailfrom = context.mailfrom
      end

      def to_s
        context.authorization_exempt ? nil : "Received-SPF: #{@spf_result} (mailfrom) identity=mailfrom; client-ip=#{@client_ip}; helo=#{@heloname}; envelope-from=#{@mailfrom}"
      end
    end
  end
end
