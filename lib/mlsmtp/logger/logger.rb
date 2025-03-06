module SMTPServer
  module Logger
    @@colors = {
      info: :light_green,
      warn: :light_red,
      error: :red
    }

    conf = Config.active["logger"]

    @@log_to_stdout = conf["log_to_stdout"]
    @@log_to_files = conf["log_to_files"]
    @@stdout_colors = conf["stdout_colors"]
    @@strftime = conf["time_format"]
    @@max_verbosity_level = conf["max_verbosity_level"]

    def self.log(message, origin: "System", type: :info, verbose: 0)
      unless verbose <= @@max_verbosity_level || @@max_verbosity_level < 0
        return false
      end

      line = format_line(message, origin: origin, type: type)

      if @@log_to_stdout
        STDOUT.puts(
          @@stdout_colors ? line.color(@@colors[type]) : line
        )
      end

      @@log_to_files.each do |file|
        File.write(file, "#{line}\n", mode: ?a)
      end
    end

    def self.format_line(message, origin:, type:)
      time_text = "[#{Time.now.strftime(@@strftime)}]"
      type_text = "[#{type.to_s.upcase}]"
      origin_text = "[#{origin}]"

      return "#{time_text} #{type_text} #{origin_text}: #{message}"
    end
  end
end
