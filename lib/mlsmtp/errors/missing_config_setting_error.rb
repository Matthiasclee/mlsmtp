module SMTPServer
  module Errors
    class MissingConfigSettingError < StandardError
      def initialize(missing_settings = nil)
        @missing_settings = missing_settings
      end

      def to_s
        @missing_settings ? "Required configuration settings are missing: #{@missing_settings}" : "Required configuration settings are missing"
      end
    end
  end
end
