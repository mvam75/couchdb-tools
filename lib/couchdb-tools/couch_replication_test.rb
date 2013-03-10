module CouchDBTools

  class CouchTest
    
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
    
    def check_couch(url)
      chef_url = RestClient.get("#{url}")

      json = StringIO.new(chef_url)
      parser = Yajl::Parser.new
      data = parser.parse(json)
    end

    def graphite(number)
      begin
        message = "couch.replication.number #{number} #{Time.now.to_i}\n"
        socket = TCPSocket.open("#{@graphite_host}", "2003")
        socket.write(message)
      rescue => e
        @log.warn "Unable to process Graphite request. #{e.message}"
      ensure
        socket.close unless socket.nil?
      end
    end

    def run_replication_test
      source_url = "http://#{@source_host}:5984/chef"
      dest_url = "http://#{@username}:#{@password}@#{@dest_host}:5984/_active_tasks"

      source_update_seq = check_couch(source_url)["update_seq"]
      
      if check_couch(dest_url).empty?
        @log.warn "Replication appears to be down!"
      else
        check_couch(dest_url)[0]["status"]
        target_update_seq = check_couch(dest_url)[0]["status"].sub("W Processed source update #","").to_i

        replication_difference = (source_update_seq - target_update_seq)
        @log.info "Replication latency: #{replication_difference}"
      end
      
      graphite(replication_difference)

      if replication_difference > 500
        @log.warn "Replication is over 500!"
        Mail.deliver do
          from "#{@email_from}"
          to "#{@email_to}"
          subject 'couch db replication has fallen behind'
          body "Replication is behind! DR is #{replication_difference} behind!"
        end
      end
      if replication_difference > 5000
        @log.fatal "Replication is over 5000! Restarting Couchdb!!"
        Mail.deliver do
          from "#{@email_from}"
          to "#{@email_to}"
          subject 'couch db replication is greater than 5000. restarting couch db'
          body "Restarting couch because its behind by #{replication_difference}"
        end
        system("sudo /sbin/service couchdb restart")
      end
    end

  end

end
#CouchDBTools::CouchTest.new.run_replication_test
