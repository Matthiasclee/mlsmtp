module SMTPServer
  module Storage
    class MaildirAdapter
      def initialize(settings)
        @path = settings["path"]
        @create_mailboxes = settings["create_mailboxes"]
      end

      def add_message(user, message)
        maildir(user).add(message)
      end

      def mailbox_exists?(user)
        return false if user.to_s == ""
        File.exist?(maildir_path(user)) || @create_mailboxes
      end

      def initialize_mailbox(user)
        md_path = maildir_path(user)
        Maildir.new(md_path)

        return md_path
      end

      private

      def maildir(user)
        raise Errors::NonexistentMailboxError, user unless mailbox_exists?(user)

        Maildir.new(maildir_path(user))
      end

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
