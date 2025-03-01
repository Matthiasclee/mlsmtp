module SMTPServer
  module Handlers
    class GenericClientHandler
      def initialize(context)
        @context = context
      end

      def handle_client
        until @context.current_status == :done
          case @context.current_status
          when :new_connection
            @context.send_banner
          end
        end
      end
    end
  end
end
