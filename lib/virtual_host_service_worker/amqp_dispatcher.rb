module VirtualHostServiceWorker
  
  class AmqpDispatcher
    
    ##
    # dispatches amqp-messages to method calls
    #
    def self.dispatch(payload)
      if payload['ssl_certificate'] and payload['ssl_ca_certificate'] and payload['ssl_key']
        DaemonKit.logger.info("added a new vhost")
        VirtualHostServiceWorker::NginxVHostWriter.setup_v_host(payload)
      elsif payload['action'] == 'delete'
        DaemonKit.logger.info("deleted a vhost")
        VirtualHostServiceWorker::NginxVHostWriter.delete_v_host(payload['server_name'])
      end
    end
  end
  
end