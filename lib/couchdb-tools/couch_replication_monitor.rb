module CouchDBTools

  class CouchMonitor

    def initialize
      @config = ConfigureTool.new.configure
      @username = @config["configuration"]["username"]
      @password = @config["configuration"]["password"]
      @local_server = @config["configuration"]["dest_host"]
    end

    def get_replication_status
      tasks = ::RestClient.get("http://#{@username}:#{@password}@#{@local_server}:5984/_active_tasks")
      unless tasks["Replication"]
        puts "Replication not running!"
        init_replication("#{@remote_server}", "#{@local_server}")
        mailit("Replication not running on "+Socket.gethostname+"!", "Trying to start replication.")
      else
        puts "Replication is running."
      end
    end

    def mailit(subject, body)
      Mail.deliver do
        from "#{@from}"
        to "#{@to}"
        subject "#{subject}"
        body "#{body}"
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
          response = ::RestClient.post "http://#{@username}:#{@password}@#{@local_server}:5984/_replicate", config_data.to_json, :content_type => :json

          unless response.code == 202
            puts "Replication to #{target}/#{db} failed with #{response.code}. Please investigate."
            mailit("replication to " +Socket.gethostname+"/#{db} has failed with #{response.code}", "Replication has failed from #{source} to #{target}("+Socket.gethostname+"). Please investigate.")
          end

        end
      rescue => e
        puts "#{e.message}"
      end
    end

  end

end

CouchDBTools::CouchMonitor.new.get_replication_status
