module CouchDBTools
  class ConfigureTool

    def initialize(config = File.join(File.dirname(__FILE__), "../../config.json"))
      @config = config
    end

    def configure
      JSON.parse(File.read(@config))
    end

  end
end
