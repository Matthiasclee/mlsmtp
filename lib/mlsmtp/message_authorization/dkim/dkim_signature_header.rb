module SMTPServer
  module MessageAuthorization
    class DKIMSignatureHeader
      @@dkim_maps = JSON.parse(
        JSON.parse(
          Config.active["dkim_maps"]
        )
      )

      def initialize(context)
        @email_domain = Transport::Destination.new(context.mailfrom, get_servers: false).addr_domain
        map = @@dkim_maps[@email_domain]

        if map
          @message_encoded = Mail.read_from_string(context.data).encoded
          @key = SSL::Certificate[map["keypair"]].key
          @domain = map["domain"]
          map["selector"] = [ map["selector"] ] if map["selector"].is_a?(String)
          @selector = map["selector"].length == 1 ? map["selector"][0] : map["selector"][rand(0...map["selector"].length)]

          begin
            @signature_header = Dkim::SignedMail.new(
              @message_encoded,
              domain: @domain,
              selector: @selector,
              private_key: @key
            )
              .dkim_header
              .value
          rescue
            @signature_header = nil
          end
        end
      end

      def to_s
        @signature_header
      end
    end
  end
end
