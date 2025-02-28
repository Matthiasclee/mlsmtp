module SMTPServer
  module SMTP
    class Response
      VALID_CODE_REGEX = /^[1-5][0-5][0-9]$/

      @@statuses = {
        information: 1,
        positive_completed: 2,
        positive_intermediate: 3,
        negative_temporary: 4,
        negative_permanent: 5
      }

      @@categories = {
        syntax: 0,
        information: 1,
        connections: 2,
        authentication: 3,
        unspecified: 4,
        mail_system: 5
      }

      def initialize(status: nil, category: nil, detail: nil, code: nil, message: nil)
        if status && category && detail
          status = @@statuses[status] if status.is_a?(Symbol)
          category = @@categories[category] if status.is_a?(Symbol)

          raise Errors::BadCodeError, [:status, status] unless (1..5).include?(status)
          raise Errors::BadCodeError, [:category, category] unless (0..5).include?(category)
          raise Errors::BadCodeError, [:detail, detail] unless (0..9).include?(detail)

          @status, @category, @detail = [status, category, detail]
        elsif code
          raise Errors::BadCodeError, [:fullcode, code] unless code.to_s.match?(VALID_CODE_REGEX)

          @status, @category, @detail = code.to_s.split("").map(&:to_i)
        else
          missing_codes = []
          missing_codes << :status unless status
          missing_codes << :category unless category
          missing_codes << :detail unless detail

          raise Errors::BadCodeError, [:missingelements, missing_codes]
        end

        @message = message
      end

      def code
        "#{@status}#{@category}#{@detail}"
      end

      def to_s
        to_a.join("\r\n")
      end

      def to_a
        if @message.is_a?(Array)
          response = []

          @message.each_with_index do |line, index|
            if index != 0 && index == message.length - 1
              response << "#{code} #{line}"
            else
              response << "#{code}-#{line}"
            end
          end
        else
          message = @message ? " #{@message}" : nil
          response = [ "#{code}#{message}" ]
        end

        return response
      end

      def self.parse(response)
        response = response.split(/\r?\n/) if response.is_a?(String)

        if is_multiline_incomplete?(response[0]) && is_multiline_incomplete?(response[-1])
          return :incomplete
        end

        code = response[0].split(/[\-\s]/, 2)[0]
        message = response.map{ |rline| rline.split(/[\-\s]/, 2)[-1] }

        message = message[0] if message.length == 1

        new(
          code: code,
          message: message
        )
      end

      private
      
      def self.is_multiline_incomplete?(line)
        line[3] == ?-
      end

      attr_accessor :status, :category, :detail, :message
    end
  end
end
