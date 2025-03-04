module SMTPServer
  module Storage
    class MailDir
      def initialize(path:)
        @path = path
      end

      def add_message(user, message)
        maildir(user).add(message)
      end

      def maildir(user)
        Maildir.new(maildir_path(user))
      end

      private

      def maildir_path(user)
        substitute_specials(
          @path,
          user: user
        )
      end

      def substitute_specials(string, user:)
        string
          .gsub("%u", user)
      end
    end
  end
end
