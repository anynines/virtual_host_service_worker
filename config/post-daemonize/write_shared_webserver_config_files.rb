return if APP_CONFIG['use_haproxy'] == true

puts '=> write_shared_webserver_config_files'
VirtualHostServiceWorker::NginxVHostWriter.write_shared_webserver_config_files
