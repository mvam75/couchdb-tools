module CouchDBTools
  module MailIt

    def mailit(subject, body)
      @log = CouchDBTools::DBLogger.log

      data = CouchDBTools::ConfigureTool.config["configuration"]
      data.each do |k, v|
        instance_variable_set("@#{k}", v)
      end

      from = @email_from
      to   = @email_to

      Mail.deliver do
        from "#{from}"
        to "#{to}"
        subject "#{subject}"
        body "#{body}"
      end
    end

  end
end