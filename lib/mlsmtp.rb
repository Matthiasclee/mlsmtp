module SMTPServer
  @@files = [] # All gem files
  @@exe = ["mlsmtpd", "mlsmtpconsole"] # All executables

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


SMTPServer.file_paths(relative:true).each do |f|
  require_relative f
end

