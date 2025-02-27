module SMTPServer
  module SMTP
    class Response
      @@statuses = {
        positive_completed: 2,
        positive_intermediate: 3
      }

      def initialize(status:, category:, detail:)
    end
  end
end
