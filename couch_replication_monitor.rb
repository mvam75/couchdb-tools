require 'restclient'
require 'mail'
require 'json'
require 'socket'

def get_replication_status
    tasks = RestClient.get("http://password:password@localhost:5984/_active_tasks")
    unless tasks["Replication"]
        puts "Replication not running!"
        init_replication("remotehost", "localhost")
        mailit("Replication not running on phl1chefdb01!", "Trying to start replication.")
        else
        puts "Replication is running."
    end
end

def mailit(subject, body)
    Mail.deliver do
        from "couchdb@example.com"
        to "user@example.com"
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
            config = {
                'source' => "http://user:password@#{source}:5984/#{db}",
                'target' => "http://user:password@#{target}:5984/#{db}",
                'continuous' => true
            }
            response = RestClient.post "http://user:password@localhost:5984/_replicate", config.to_json, :content_type => :json
            
            unless response.code == 202
                puts "Replication to #{target}/#{db} failed with #{response.code}. Please investigate."
                mailit("replication to " +Socket.gethostname+"/#{db} has failed with #{response.code}", "Replication has failed from #{source} to #{target}("+Socket.gethostname+"). Please investigate.")
            end
            
        end
    rescue => e
        puts "#{e.message}"
    end
end

get_replication_status
