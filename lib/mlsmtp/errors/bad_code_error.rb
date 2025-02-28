module SMTPServer
  module Errors
    class BadCodeError < StandardError
      def initialize(position, example)
        @position = position
        @example = example
      end

      def to_s
        if position == :fullcode
          "Bad code `#{@example}`"
        elsif position == :missingelements
          "Missing element(s) #{@example}"
        else
          "Bad element `#{@example}` in #{@position} position in status code"
        end
      end

      attr_reader :position, :example
    end
  end
end
