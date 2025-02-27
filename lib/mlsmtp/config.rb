module SMTPServer
  class Config
    @@required_conf_settings = [
    ]

    def initialize(conf_settings:{})
      missing_settings = @@required_conf_settings - conf_settings.keys
      
      unless missing_settings.empty?
        raise MissingConfError
      end  
    end
  end
end
