module CouchDBTools
  class DBLogger

    def self.config(options = {})
      file = options['log_file']
      level = options['log_level']
      rotation = options['rotation']

      file ||= STDOUT
      level ||= 'info'
      rotation ||= 'daily'

      @@log = Logger.new(file, rotation)
      @@log.level = Logger.const_get(level.upcase.to_sym)

      @@log.formatter = proc do |severity, datetime, progname, msg|
       "#{datetime}: [#{severity}] : #{msg}\n"
      end
      #@@log.info "Logger started with a level of #{log_level.upcase}."
    end

    def self.log
      @@log
    end

  end
end
