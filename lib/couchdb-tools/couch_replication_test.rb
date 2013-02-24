module CouchDBTools

  class CouchTest

    def initialize
      @config = ConfigureTool.new.configure
      @username = @config["configuration"]["username"]
      @password = @config["configuration"]["password"]
      @local_server = @config["configuration"]["dest_host"]
      @remote_server = @config["configuration"]["source_host"]
      @graphite_server = @config["configuration"]["graphite_host"]
      @from = @config["configuration"]["email_from"]
      @to = @config["configuration"]["email_to"]
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
        socket = TCPSocket.open("#{@graphite_server}", "2003")
        socket.write(message)
      rescue => e
        puts "Unable to process Graphite request. #{e.message}"
      ensure
        socket.close unless socket.nil?
      end
    end

    def run_replication_test
      source_url = "http://#{@remote_server}:5984/chef"
      dest_url = "http://#{@username}:#{@password}@#{@local_server}:5984/_active_tasks"

      source_update_seq = check_couch(source_url)["update_seq"]
      
      if check_couch(phl1_url)[0]["status"]
        target_update_seq = check_couch(dest_url)[0]["status"].sub("W Processed source update #","").to_i

        replication_difference = (source_update_seq - target_update_seq)
        puts replication_difference
      else
        puts "Replication appears to be down."
      end
      
      graphite(replication_difference)

      if replication_difference >= 500
        Mail.deliver do
          from "#{@from}"
          to "#{@to}"
          subject 'couch db replication has fallen behind'
          body "Replication is behind! DR is #{replication_difference} behind!"
        end
      end
      if replication_difference >= 5000
        Mail.deliver do
          from "#{@from}"
          to "#{@to}"
          subject 'couch db replication is greater than 5000. restarting couch db'
          body "Restarting couch because its behind by #{replication_difference}"
        end
        system("sudo /sbin/service couchdb restart")
      end
    end

  end

end
CouchDBTools::CouchTest.new.run_replication_test
