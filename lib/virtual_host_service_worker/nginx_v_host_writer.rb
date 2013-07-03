require 'erubis'

module VirtualHostServiceWorker
  class NginxVHostWriter < VHostWriter
    
    def self.setup_v_host(payload)
      write_bundled_certificates(payload['server_name'],
                                 payload['ssl_ca_certificate'],
                                 payload['ssl_certificate'])
      
      write_ssl_key(payload['server_name'], payload['ssl_key'])
      
      write_webserver_config(payload['server_name'])
      
      reload_config
    end
    
    protected
    
    def self.write_webserver_config(server_name)
      
      template_file = File.join(File.dirname(__FILE__), '..', '..', 'templates', 'nginx_v_host.erb')
      template = Erubis::Eruby.new(File.read(template_file))
      
      v_host_file = File.join(APP_CONFIG['v_host_config_dir'].split('/'), "#{server_name}.conf")
      v_host_config = template.result(:server_name => server_name, :routers => APP_CONFIG['routers'])
      
      File.open(v_host_file, 'w') do |f|
        f.write(v_host_config)
      end
      
    end
    
    def self.write_ssl_key(server_name, key)
      pem_file = File.join(APP_CONFIG['cert_dir'].split('.'), "#{server_name}.key")
      
      File.open(pem_file, 'w') do |f|
        f.write(key)
      end
    end
    
    def self.write_bundled_certificates(server_name, ca_cert, cert)
      pem_file = File.join(APP_CONFIG['cert_dir'].split('/'), "#{server_name}.pem")
      
      File.open(pem_file, 'w') do |f|
        f.write(cert)
        f.write("\n")
        f.write(ca_cert)
      end
      
    end
    
    def self.reload_config
      #TODO: `/etc/init.d/nginx reload`
    end
  end
end