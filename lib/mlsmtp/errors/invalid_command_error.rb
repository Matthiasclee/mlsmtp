module SMTPServer
  module Errors
    class InvalidCommandError < StandardError
      def initialize(command)
        @command = command
      end

      def to_s
        "Command `#{command}` is not a valid command"
      end

      attr_accessor :command
    end
  end
end
