module CouchDBTools
  class ConfigureTool

    def self.configure(config)
    raise ArgumentError, 'Usage: couchdb-tools config.json' if config.nil?
      @config = JSON.parse(File.read(config))
    end

    def self.config
      @config
    end

  end
end
