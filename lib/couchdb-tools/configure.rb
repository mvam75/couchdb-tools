module CouchDBTools
  class ConfigureTool

    def self.configure(config = File.join(File.dirname(__FILE__), "../../config.json"))
      @config = JSON.parse(File.read(config))
    end

  end
end