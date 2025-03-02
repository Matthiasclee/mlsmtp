module SMTPServer
  module SMTP
    class Command
      VALID_SMTP_COMMANDS = [
        [ "HELO", String ],
        [ "MAIL", "FROM:", String ],
        [ "RCPT", "TO:", String ],
        [ "DATA" ],
        [ "QUIT" ],
        [ "RSET" ],
        [ "VRFY" ],
        [ "NOOP" ]
      ]

      def initialize(command, values = [])
        @command = command
        @values = values

        @command = @command.split(" ") unless @command.is_a?(Array)
        @values = [ @values ] unless @values.is_a?(Array)

        @command.map!(&:upcase)

        Command.parse_command(to_s)
      end

      def to_s
        "#{@command.join(" ")}#{" " unless @values.empty?}#{@values.join(" ")}"
      end

      def self.parse(full_command)
        parsed_command, command_template = parse_command(full_command)

        command, values = dissect_array(parsed_command, command_template)

        new(command, values)
      end

      def self.all_valid_commands
        VALID_SMTP_COMMANDS
      end

      attr_accessor :command, :values

      private

      def self.dissect_array(command_array, template_array)
        args_start = template_array.index(String)
        return [ command_array ] unless args_start

        command_strings_end = args_start - 1

        return [
          command_array[0..command_strings_end],
          command_array[args_start..-1]
        ]
      end

      def self.parse_command(command)
        Command.all_valid_commands.each do |command_template|
          case command_matches_array?(command, command_template)
          when true
            return [
              command.split(" ", command_template.length),
              command_template
            ]
          when :incomplete
            raise Errors::IncompleteCommandError, [command, command_template]
          when false
            next
          end
        end

        raise Errors::InvalidCommandError, command
      end

      def self.command_matches_array?(command, array)
        command = command.split(" ", array.length)

        array.each_with_index do |element, index|
          value = command[index]

          if element.class == String
            return false unless value.to_s.upcase.gsub(" ", "") == element
          else
            if element != value.class
              return :incomplete
            end
          end
        end

        return true
      end
    end
  end
end
