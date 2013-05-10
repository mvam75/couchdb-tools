module CouchDBTools

  module Scheduler

    def config
      data = CouchDBTools::ConfigureTool.config["configuration"]["scheduler"]
      data.each do |k,v|
        instance_variable_set("@#{k}",v)
      end
    end

	  scheduler = Rufus::Scheduler.start_new

	  scheduler.every "#{@status_timer}" do
	    CouchMonitor.new.get_replication_status
	  end

	  scheduler.every "#{@test_timer}" do
	    CouchTest.new.run_replication_test
	  end
  end
end