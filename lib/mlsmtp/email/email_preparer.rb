module SMTPServer
  module Email
    class EmailPreparer
      def initialize(smtp_context)
        @context = smtp_context
        @raw_email = @context.data
        @parsed_email = Mail.read_from_string(@raw_email)
      end

      def set_header(h, v)
        @parsed_email.header[h] = v
      end

      def add_all_headers
        set_header("Received", @context)
      end

      def to_s
        @parsed_email.to_s
      end

      attr_reader :context, :raw_email, :parsed_email
    end
  end
end
