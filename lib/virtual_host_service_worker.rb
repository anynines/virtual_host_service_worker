module VirtualHostServiceWorker
  autoload :VHostWriter, 'virtual_host_service_worker/v_host_writer.rb'
  autoload :AmqpDispatcher, 'virtual_host_service_worker/amqp_dispatcher.rb'
  autoload :HaproxyVHostWriter, 'virtual_host_service_worker/haproxy_v_host_writer.rb'
  autoload :NginxVHostWriter, 'virtual_host_service_worker/nginx_v_host_writer.rb'
end
