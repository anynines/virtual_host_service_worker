module VirtualHostServiceWorker
  
  class AmqpDispatcher
    
    ##
    # dispatches amqp-messages to method calls
    #
    def self.dispatch(payload)
      DaemonKit.logger.info("AMQP message received")
      if payload['ssl_certificate'] and payload['ssl_ca_certificate'] and payload['ssl_key']
        DaemonKit.logger.info("added a new vhost")
        
        if APP_CONFIG['use_ha_proxy'] == true
          VirtualHostServiceWorker::HaProxyVHostWriter.setup_v_host(payload)
        else
          VirtualHostServiceWorker::NginxVHostWriter.setup_v_host(payload)
        end

      elsif payload['action'] == 'delete'
        DaemonKit.logger.info("deleted a vhost")

        if APP_CONFIG['use_ha_proxy'] == true
          VirtualHostServiceWorker::HaProxyVHostWriter.delete_v_host(payload['server_name'])
        else
          VirtualHostServiceWorker::NginxVHostWriter.delete_v_host(payload['server_name'])
        end

      end
    end
  end
  
end