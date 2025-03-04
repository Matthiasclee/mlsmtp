module SMTPServer
  module Storage
    adapter = Config.active["mail_storage"]["adapter"]
    path = Config.active["mail_storage"]["path"]
    Active = Object.const_get(adapter).new(
      path: path
    )
  end
end
