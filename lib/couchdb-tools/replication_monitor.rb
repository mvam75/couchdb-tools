module CouchDBTools

  class CouchMonitor

    include CouchDBTools::MailIt

    def initialize
      @log = CouchDBTools::DBLogger.log
      config
    end

    def config
      data = CouchDBTools::ConfigureTool.config["configuration"]
      data.each do |k,v|
        instance_variable_set("@#{k}",v)
      end
    end
    
    def get_replication_status
      tasks = ::RestClient.get("http://#{@username}:#{@password}@#{@dest_host}:5984/_active_tasks")
      @log.info "Check that replication is running."
      unless tasks["Replication"]
        @log.warn "Replication not running!"
        mailit("Replication not running on "+Socket.gethostname+"!", "Trying to start replication.")
        init_replication("#{@source_host}", "#{@dest_host}")
        sleep 10
        mailit("Replication was started on "+Socket.gethostname+"!", "Replication was started successfully.") unless tasks["Replication"].empty?
      else
        @log.info "Replication is running."
      end
    end

    def init_replication(source_server, target_server)
      begin
        source = "#{source_server}"
        target = "#{target_server}"
        databases = ['chef']

        databases.each do |db|
          config_data = {
            'source' => "http://#{@username}:#{@password}@#{source}:5984/#{db}",
            'target' => "http://#{@username}:#{@password}@#{target}:5984/#{db}",
            'continuous' => true
          }
          @log.info "Sending a HTTP POST to #{target}:5984/_replicate"
          response = ::RestClient.post "http://#{@username}:#{@password}@#{target}:5984/_replicate", config_data.to_json, :content_type => :json

          unless response.code == 202
            @log.warn "Replication to #{target}/#{db} failed with #{response.code}. Please investigate."
            mailit("replication to " +Socket.gethostname+"/#{db} has failed with #{response.code}", "Replication has failed from #{source} to #{target}("+Socket.gethostname+"). Please investigate.")
          end

        end
      rescue => e
        @log.error "#{e.message}"
      end
    end

  end

end