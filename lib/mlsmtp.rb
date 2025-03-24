Dir.chdir(File.expand_path('..', __dir__))

require "spf"
require "dkim"
require "rpam"
require "json"
require "mail"
require "base64"
require "ipaddr"
require "rbtext"
require "rbtext/string_methods"
require "socket"
require "resolv"
require "sqlite3"
require "openssl"
require "maildir"
require "argparse"

module SMTPServer
  @@preload_files = [
    "errors/bad_code_error.rb",
    "errors/missing_config_setting_error.rb",
    "errors/incomplete_command_error.rb",
    "errors/invalid_command_error.rb",
    "errors/nonexistent_mailbox_error.rb",
    "errors/server_rejection_error.rb",
    "errors/bad_auth_rule_error.rb",
    "config.rb",
  ]

  @@normal_files = [
    "smtp/commands.rb",
    "smtp/responses.rb",
    "smtp/banner.rb",
    "smtp/smtp_client_context.rb",
    "smtp/smtp_server_context.rb",
    "servers/mailserver.rb",
    "handlers/generic_client_handler.rb",
    "handlers/smtp_server_handler.rb",
    "handlers/smtp_command_handlers/ehlo.rb",
    "handlers/smtp_command_handlers/starttls.rb",
    "handlers/smtp_command_handlers/helo.rb",
    "handlers/smtp_command_handlers/mailfrom.rb",
    "handlers/smtp_command_handlers/rcptto.rb",
    "handlers/smtp_command_handlers/data.rb",
    "handlers/smtp_command_handlers/quit.rb",
    "handlers/smtp_command_handlers/rset.rb",
    "handlers/smtp_command_handlers/vrfy.rb",
    "handlers/smtp_command_handlers/expn.rb",
    "handlers/smtp_command_handlers/noop.rb",
    "handlers/smtp_command_handlers/auth.rb",
    "handlers/smtp_server_command_handlers/ehlo.rb",
    "handlers/smtp_server_command_handlers/helo.rb",
    "handlers/smtp_server_command_handlers/starttls.rb",
    "handlers/smtp_server_command_handlers/quit.rb",
    "handlers/smtp_server_command_handlers/mailfrom.rb",
    "handlers/smtp_server_command_handlers/rcptto.rb",
    "handlers/smtp_server_command_handlers/data.rb",
    "transport/rules.rb",
    "transport/authorization.rb",
    "transport/authorization_handler.rb",
    "transport/destination.rb",
    "transport/local_delivery_agent.rb",
    "transport/remote_delivery_agent.rb",
    "storage/maildir.rb",
    "database/sqlite.rb",
    "queue/queued_message.rb",
    "queue/queue_worker.rb",
    "queue/queue_handler.rb",
    "email/email_preparer.rb",
    "email/headers/received.rb",
    "email/error_email.rb",
    "email/error_email_generator.rb",
    "logger/logger.rb",
    "ssl/certificates.rb",
    "authentication/pam.rb",
    "authentication/debug.rb",
    "authentication/login_handler.rb",
    "authentication/plain_handler.rb",
    "mail_lists/mail_list.rb",
    "message_authorization/spf/authorize_spf.rb",
    "message_authorization/spf/header.rb",
    "message_authorization/dkim/dkim_signature_header.rb",
  ]
  @@adapters = [
    "storage/storage.rb",
    "database/database.rb",
    "authentication/auth_adapter.rb",
  ]
  @@additional_files = [
    "conf/default.json",
    "conf/tranaport_rules.json",
    "conf/tranaport_authorization.json",
    "conf/intialize_db.sql",
    "emails/bad_mailbox.eml",
    "emails/delivery_failed.eml"
  ]
  @@exe = [
    "mlsmtpd",
    "mlsmtplist",
    "mlsmtpqueue"
  ]

  def self.version
    "0.0.1"
  end

  def self.additional_files
    @@additional_files
  end

  def self.executables
    @@exe
  end

  def self.normal_files
    @@normal_files
  end

  def self.adapters
    @@adapters
  end

  def self.preload_files
    @@preload_files
  end

  def self.file_paths(relative:false)
    x = (@@normal_files + @@adapters).map do |f|
      "#{"lib/" unless relative}mlsmtp/#{f}"
    end

    if relative
      return x
    else
      return x + ['lib/mlsmtp.rb']
    end
  end

  def self.load_preload
    preload_files.each do |f|
      require_relative "mlsmtp/#{f}"
    end
  end

  def self.load_remaining
    normal_files.each do |f|
      require_relative "mlsmtp/#{f}"
    end

    Config.active["additional_requires"].each do |r|
      require r
    end

    adapters.each do |f|
      require_relative "mlsmtp/#{f}"
    end

    Thread.abort_on_exception = SMTPServer::Config.active["threads"]["abort_on_exception"]
    Thread.report_on_exception = SMTPServer::Config.active["threads"]["report_on_exception"]
  end
end
