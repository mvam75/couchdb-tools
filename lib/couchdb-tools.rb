require 'restclient'
require 'logger'
require 'yajl'
require 'mail'
require 'socket'
require 'json'
require 'rufus/scheduler'
require 'eventmachine'

Dir[File.join(File.dirname(__FILE__), "**", "*.rb")].each {|file| require file}

module CouchDBTools

  def self.start(opts)
    #DBLogger.config(:file => "~/couch_monitor.log", :level => 'info', :rotation => 'daily')
    CouchDBTools::ConfigureTool.configure(opts)
    DBLogger.config(ConfigureTool.config["logger"])

      begin
        EM.run do
	        Scheduler	
	    end

      rescue => e
        DBLogger.log.fatal "Monitor failed with the following issue #{e.message}"
      end
  end

end
