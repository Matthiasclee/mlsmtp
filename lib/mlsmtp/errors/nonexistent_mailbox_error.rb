module SMTPServer
  module Errors
    class NonexistentMailboxError < StandardError
      def initialize(path)
        @path = path
      end

      def to_s
        "Mailbox `#{@path}` does not exist."
      end

      attr_reader :path
    end
  end
end
