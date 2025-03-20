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
        Config.active["header_adapters"].each do |header, adapter|
          value = Object.const_get(adapter).new(@context)
          next unless value
          set_header(header, value.to_s)
        end
      end

      def to_s
        @parsed_email.to_s
      end

      attr_reader :context, :raw_email, :parsed_email
    end
  end
end
