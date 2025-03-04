module SMTPServer
  module Database
    database_config = Config.active["database"]["config"]
    adapter = Config.active["database"]["adapter"]
    Active = Object.const_get(adapter).new(database_config)
  end
end
