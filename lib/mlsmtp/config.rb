module SMTPServer
  class Config
    @@required_conf_settings = [
    ]

    def initialize(conf_settings = {})
      missing_settings = @@required_conf_settings - conf_settings.keys
      
      unless missing_settings.empty?
        raise Errors::MissingConfigSettingError, missing_settings
      end

      @settings = conf_settings
    end

    def setting(k)
      @settings[k]
    end

    def setting=(k, v)
      @settings[k] = v
    end

    def self.from_json(text)
      new(JSON.parse(text))
    end

    def self.from_file(filename)
    end

    def self.required_conf_settings()
      @@required_conf_settings
    end

    attr_accessor :settings
  end
end
