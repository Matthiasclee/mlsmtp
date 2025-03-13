module SMTPServer
  module Authentication
    adapter = Object.const_get(
      Config.active["authentication"]["adapter"]
    ).new(
      Config.active["authentication"]["config"]
    )

    Active = adapter
  end
end
