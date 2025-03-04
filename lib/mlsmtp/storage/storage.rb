module SMTPServer
  module Storage
    storage_config = Config.active["mail_storage"]["config"]
    adapter = Config.active["mail_storage"]["adapter"]
    Active = Object.const_get(adapter).new(storage_config)
  end
end
