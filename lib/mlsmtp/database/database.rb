module SMTPServer
  module Database
    def self.connect
      database_config = Config.active["database"]["config"]
      adapter = Config.active["database"]["adapter"]
      @@active = Object.const_get(adapter).new(database_config)
    end

    def self.active
      @@active
    end
  end
end
