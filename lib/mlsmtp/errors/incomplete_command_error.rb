module SMTPServer
  module Errors
    class IncompleteCommandError < StandardError
      def initialize(original_command, template_command)
        @original_command = original_command
        @template_command = template_command
      end

      def to_s
        "Command `#{@original_command}` is incomplete (does not match template `#{template_command}`)"
      end

      attr_accessor :original_command, :template_command
    end
  end
end
