module SMTPServer
  module Email
    module ErrorEmails
      class DeliveryFailed
        def initialize(original_from:, original_to:)
          @og_from = original_from
          @og_to = original_to
          @contact_email = Config.active["contact_email"]
          @server_name = Config.active["banner"]["banner_server_name"]
        end

        def raw_original_text
          path = Config.active["error_emails"]["delivery_failed"]
          return false unless File.exist?(path)

          return File.read(path)
            .gsub("<<!SERVERNAME!>>", @server_name)
            .gsub("<<!CONTACTADDR!>>", @contact_email)
            .gsub("<<!RECIPIENT!>>", @og_to)
            .gsub("<<!SENDERADDR!>>", @og_from)
        end

        def prepared_email
          email_text = raw_original_text
          return false unless email_text

          Mail.read_from_string(email_text).to_s
        end

        attr_reader :og_from, :og_to, :contact_email, :server_name
      end
    end
  end
end
