# Created with create_new_gem by Matthias Lee

require_relative "lib/mlsmtp.rb"

Gem::Specification.new do |mlsmtp|
  mlsmtp.name        = 'mlsmtp'
  mlsmtp.version     = SMTPServer.version
  mlsmtp.summary     = "SMTP server"
  mlsmtp.description = "SMTP server"
  mlsmtp.authors     = ["Matthias Lee"]
  mlsmtp.email       = 'matthias@matthiasclee.com'
  mlsmtp.files       = SMTPServer.file_paths + SMTPServer.executables.map{|i|"bin/#{i}"}
  mlsmtp.executables = SMTPServer.executables
  mlsmtp.require_paths = ['lib']
  
  mlsmtp.homepage = 'https://github.com/Matthiasclee/mlsmtp'
  mlsmtp.license = 'CC-BY-NC-SA-4.0'
end
