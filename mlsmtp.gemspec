require_relative "lib/mlsmtp.rb"

Gem::Specification.new do |mlsmtp|
  mlsmtp.name        = 'mlsmtp'
  mlsmtp.version     = SMTPServer.version
  mlsmtp.summary     = "Ruby SMTP server"
  mlsmtp.description = "Highly configurable and flexible SMTP server written in pure ruby"
  mlsmtp.authors     = ["Matthias Lee"]
  mlsmtp.email       = 'matthias@matthiasclee.com'
  mlsmtp.files       = SMTPServer.preload_files.map{|x|"lib/mlsmtp/#{x}"} + SMTPServer.file_paths + SMTPServer.executables.map{|i|"bin/#{i}"} + SMTPServer.additional_files
  mlsmtp.executables = SMTPServer.executables
  mlsmtp.require_paths = ['lib']
  mlsmtp.required_ruby_version = ">= 3.0"

  mlsmtp.add_runtime_dependency "etc", "~> 1.4.2"
  mlsmtp.add_runtime_dependency "spf", "~> 0.1.1"
  mlsmtp.add_runtime_dependency "dkim", "~> 1.1.0"
  mlsmtp.add_runtime_dependency "json", "~> 2.6.3"
  mlsmtp.add_runtime_dependency "mail", "~> 2.8.1"
  mlsmtp.add_runtime_dependency "ipaddr", "~> 1.2.7"
  mlsmtp.add_runtime_dependency "rbtext", "~> 0.3.5"
  mlsmtp.add_runtime_dependency "resolv", "~> 0.3.0"
  mlsmtp.add_runtime_dependency "sqlite3", "~> 2.6.0"
  mlsmtp.add_runtime_dependency "maildir", "~> 2.2.3"
  mlsmtp.add_runtime_dependency "openssl", "~> 3.1.0"
  mlsmtp.add_runtime_dependency "argparse", "~> 0.0.5"
  mlsmtp.add_runtime_dependency "rpam-ruby19", "~> 1.2.1"

  mlsmtp.homepage = 'https://github.com/Matthiasclee/mlsmtp'
  mlsmtp.license = 'CC-BY-NC-SA-4.0'
end
