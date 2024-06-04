if APP_CONFIG["use_haproxy"] == true
  return
else
  puts "=> write_shared_webserver_config_files"
  VirtualHostServiceWorker::NginxVHostWriter.write_shared_webserver_config_files 
end