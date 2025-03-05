module SMTPServer
  @@files = [
    "config.rb",
    "errors/bad_code_error.rb",
    "errors/missing_config_setting_error.rb",
    "errors/incomplete_command_error.rb",
    "errors/invalid_command_error.rb",
    "errors/nonexistent_mailbox_error.rb",
    "smtp/commands.rb",
    "smtp/responses.rb",
    "smtp/banner.rb",
    "smtp/smtp_client_context.rb",
    "servers/mailserver.rb",
    "handlers/generic_client_handler.rb",
    "handlers/smtp_command_handlers/helo.rb",
    "handlers/smtp_command_handlers/mailfrom.rb",
    "handlers/smtp_command_handlers/rcptto.rb",
    "handlers/smtp_command_handlers/data.rb",
    "handlers/smtp_command_handlers/quit.rb",
    "handlers/smtp_command_handlers/rset.rb",
    "handlers/smtp_command_handlers/noop.rb",
    "transport/rules.rb",
    "transport/destination.rb",
    "storage/maildir.rb",
    "storage/storage.rb",
    "database/sqlite.rb",
    "database/database.rb",
    "queue/queued_message.rb",
    "queue/queue_worker.rb",
    "queue/queue_handler.rb",
  ]
  @@exe = [
    "mlsmtpd",
    "mlsmtpconsole"
  ]

  def self.version
    "0.0.1"
  end

  def self.executables
    @@exe
  end

  def self.file_paths(relative:false)
    x = @@files.map do |f|
      "#{"lib/" unless relative}mlsmtp/#{f}"
    end

    if relative
      return x
    else
      return x + ['lib/mlsmtp.rb']
    end
  end
end

# Additional Requires
require "json"
require "socket"
require "resolv"
require "sqlite3"
require "openssl"
require "maildir"
require "argparse"

SMTPServer.file_paths(relative:true).each do |f|
  require_relative f
end
