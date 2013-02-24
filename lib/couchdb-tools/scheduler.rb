module CouchDBTools

  scheduler = Rufus::Scheduler.start_new

  scheduler.every '5m' do
    get_replication_status
  end

  scheduler.every '1m' do
    run_replication_test
  end
end