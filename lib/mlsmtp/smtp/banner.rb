module SMTPServer
  module SMTP
    class Banner
      def initialize
        @include_esmtp = Config.active["banner"]["include_esmtp_status"] && Config.active["esmtp_enable"]
        @additional_text = Config.active["banner"]["additional_text"]
        @servername = Config.active["banner"]["banner_server_name"]
        @mailname = Config.active["mailname"]

        @messageoverride = Config.active["banner"]["message_override"]
      end

      def to_s
        esmtp_text = @include_esmtp ? "ESMTP " : ""
        servername_text = @servername
        additional_text = @additional_text

        if @messageoverride
          bannertext = @messageoverride
        else
          bannertext = "#{esmtp_text}#{servername_text}#{additional_text}"
        end

        bannertext = " #{bannertext}" unless bannertext.empty?

        return "#{@mailname}#{bannertext}".strip
      end

      def to_response
        Response.new(
          status: :positive_completed,
          category: :connections,
          message: to_s
        )
      end
    end
  end
end
