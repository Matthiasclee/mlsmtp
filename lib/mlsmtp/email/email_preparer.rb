module SMTPServer
  module Email
    class EmailPreparer
      def initialize(email_text)
        @raw_email = email_text
        @parsed_email = Mail.read_from_string(@raw_email)
      end
    end
  end
end
