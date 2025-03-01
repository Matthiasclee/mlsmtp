module SMTPServer
  class Config
    @@active_config = nil

    @@required_conf_settings = [
      "mailname"
    ]

    def initialize(conf_settings = {})
      missing_settings = @@required_conf_settings - conf_settings.keys
      
      unless missing_settings.empty?
        raise Errors::MissingConfigSettingError, missing_settings
      end

      @settings = conf_settings
    end

    def [](k)
      @settings[k.to_s]
    end

    def []=(k, v)
      @settings[k.to_s] = v
    end

    def set_active
      @@active_config = self
    end

    def self.from_json(text)
      new(JSON.parse(text))
    end

    def self.from_file(filename)
      self.from_json(File.read(filename))
    end

    def self.required_conf_settings
      @@required_conf_settings
    end

    def self.active
      @@active_config
    end

    def self.clear_active
      @@active_config = nil
    end

    attr_accessor :settings
  end
end
