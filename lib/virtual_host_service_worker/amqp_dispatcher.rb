module VirtualHostServiceWorker
  
  class AmqpDispatcher
    
    ##
    # dispatches amqp-messages to methods calls
    #
    def self.dispatch(payload)
      if payload['ssl_certificate'] and payload['ssl_ca_certificate'] and payload['ssl_key']
        VirtualHostServiceWorker::NginxVHostWriter.setup_v_host(payload)
      elsif payload['action'] == 'delete'
        VirtualHostServiceWorker::NginxVHostWriter.delete_v_host(payload['server_name'])
      end
    end
  end
  
end