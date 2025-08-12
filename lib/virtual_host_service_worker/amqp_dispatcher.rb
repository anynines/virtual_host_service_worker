module VirtualHostServiceWorker

  class AmqpDispatcher

    ##
    # dispatches amqp-messages to method calls
    #
    def self.dispatch(payload)
      DaemonKit.logger.info("AMQP message received")
      begin
        if payload['action'] == "reload" && APP_CONFIG['use_haproxy'] == true
          if VirtualHostServiceWorker::HaproxyVHostWriter.haproxy_instance_limit_reached?
            #  Requeue
          else
            DaemonKit.logger.info("HAProxy - Trigger reload for #{payload['server_name']}")
            VirtualHostServiceWorker::VirtualHostServiceWorker.reload_config
          end
        end
        if payload['ssl_certificate'] and payload['ssl_ca_certificate'] and payload['ssl_key']
          DaemonKit.logger.info("adding a new vhost: #{payload['server_name']}")

          if APP_CONFIG['use_haproxy'] == true
            VirtualHostServiceWorker::HaproxyVHostWriter.setup_v_host(payload)
            DaemonKit.logger.info("HAProxy - Succesfully added vhost #{payload['server_name']}")
          else
            VirtualHostServiceWorker::NginxVHostWriter.setup_v_host(payload)
            DaemonKit.logger.info("NGINX - Succesfully added vhost #{payload['server_name']}")
          end
          DaemonKit.logger.info("Succesfully added vhost #{payload['server_name']}")

        elsif payload['action'] == 'delete'
          DaemonKit.logger.info("deleting vhost: #{payload['server_name']}")

          if APP_CONFIG['use_haproxy'] == true
            VirtualHostServiceWorker::HaproxyVHostWriter.delete_v_host(payload['server_name'])
            DaemonKit.logger.info("HAProxy - deleted vhost: #{payload['server_name']}")
          else
            VirtualHostServiceWorker::NginxVHostWriter.delete_v_host(payload['server_name'])
            DaemonKit.logger.info("NGINX - deleted vhost: #{payload['server_name']}")
          end
        end
      rescue => e
        DaemonKit.logger.error(e)
        raise
      end
    end
  end
end