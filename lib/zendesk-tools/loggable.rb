Log4r.define_levels(*Log4r::Log4rConfig::LogLevels)

module ZendeskTools
  module Loggable
    def self.logger_for(name)
      name      = self.class.name
      log       = Log4r::Logger.new(name)
      formatter = Log4r::PatternFormatter.new(:pattern => "[%l @ %d] %c: %M")

      log_file = ZendeskTools.config['log_file']
      if log_file
        FileUtils.mkdir_p File.dirname(log_file)

        log.add Log4r::FileOutputter.new(name, :filename => log_file, :formatter => formatter)
      else
        outputter = Log4r::Outputter.stdout
        outputter.formatter = formatter
        log.add outputter
      end

      level = ZendeskTools.config['log_level']
      if level
        log.level = Log4r.const_get(level.to_s.upcase)
      end

      log
    end

    def log
      @log ||= Loggable.logger_for(self.class.name)
    end
  end
end