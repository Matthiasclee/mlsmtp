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
        [ "VRFY", String ],
        [ "EXPN", String ],
        [ "NOOP" ],
      ]

      VALID_ESMTP_COMMANDS = [
        [ "EHLO", String ],
        [ "STARTTLS" ],
      ]

      @@all_valid_commands = nil

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
        unless @@all_valid_commands
          @@all_valid_commands = VALID_SMTP_COMMANDS
          @@all_valid_commands += VALID_ESMTP_COMMANDS if Config.active["esmtp_enable"]

          @@all_valid_commands = @@all_valid_commands.filter do |command|
            !Config.active["disable_commands"].include?(command[0])
          end
        end

        @@all_valid_commands
      end

      attr_accessor :command, :values

      private

      def self.split_to_array(command, command_template)
        command = command.split(" ")

        if command_template.length >= 2 && command.length >= 2 && command_template[1].is_a?(String) && command_template[1][-1] == ?: && command[1][-1] != ?:
          command_end, argument = command.delete_at(1).split(?:)
          command.insert(1, "#{command_end}:")
          command.insert(2, argument)
        end

        return command
      end

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
              split_to_array(command, command_template),
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
        command = split_to_array(command, array)

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
