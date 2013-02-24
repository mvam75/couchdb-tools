module CouchDBTools

  module Scheduler

	  scheduler = Rufus::Scheduler.start_new

	  scheduler.every '5m' do
	    CouchMonitor.new.get_replication_status
	  end

	  scheduler.every '1m' do
	    CouchTest.new.run_replication_test
	  end
  end
end