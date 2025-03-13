require_relative "lib/mlsmtp.rb"

Gem::Specification.new do |mlsmtp|
  mlsmtp.name        = 'mlsmtp'
  mlsmtp.version     = SMTPServer.version
  mlsmtp.summary     = "SMTP server"
  mlsmtp.description = "SMTP server"
  mlsmtp.authors     = ["Matthias Lee"]
  mlsmtp.email       = 'matthias@matthiasclee.com'
  mlsmtp.files       = SMTPServer.file_paths + SMTPServer.executables.map{|i|"bin/#{i}"} + SMTPServer.additional_files
  mlsmtp.executables = SMTPServer.executables
  mlsmtp.require_paths = ['lib']

  mlsmtp.add_runtime_dependency "json", "~> 2.6.3"
  mlsmtp.add_runtime_dependency "mail", "~> 2.8.1"
  mlsmtp.add_runtime_dependency "rbtext", "~> 0.3.5"
  mlsmtp.add_runtime_dependency "resolv", "~> 0.3.0"
  mlsmtp.add_runtime_dependency "sqltie3", "~> 2.6.0"
  mlsmtp.add_runtime_dependency "maildir", "~> 2.2.3"
  mlsmtp.add_runtime_dependency "openssl", "~> 3.1.0"
  mlsmtp.add_runtime_dependency "argparse", "~> 0.0.5"
  mlsmtp.add_runtime_dependency "rpam-ruby19", "~> 1.2.1"

  mlsmtp.homepage = 'https://github.com/Matthiasclee/mlsmtp'
  mlsmtp.license = 'CC-BY-NC-SA-4.0'
end
