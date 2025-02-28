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

      def initialize(command, values)
        @command = command
      end

      def parse(command)
        parsed_command = parse_command(command)
      end

      def self.all_valid_commands
        VALID_SMTP_COMMANDS
      end

      private

      def parse_command(command)
        Command.all_valid_commands.each do |command_template|
          case command_matches_array?(command, command_template)
          when true
            return command.split(command_template.length)
          when :incomplete
            raise Errors::IncompleteCommandError, [command, command_template]
          when false
            next
          end
        end

        raise Errors::InvalidCommandError, command
      end

      def command_matches_array?(command, array)
        command = command.split(" ", array.length)

        array.each_with_index do |element, index|
          value = command[index]

          if element.class == String
            return false unless element.value.to_s.upcase.gsub(" ", "") == element
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
