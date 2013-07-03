require 'erubis'

module VirtualHostServiceWorker
  class NginxVHostWriter < VHostWriter
    
    def self.setup_v_host(payload)
      
      payload['server_name'] = payload['server_name'].downcase
      payload['server_aliases'] = payload['server_aliases'].downcase if payload['server_aliases']
      
      write_bundled_certificates(payload['server_name'],
                                 payload['ssl_ca_certificate'],
                                 payload['ssl_certificate'])
      
      write_ssl_key(payload['server_name'], payload['ssl_key'])
      
      write_webserver_config(payload['server_name'], payload['server_aliases'])
      
      reload_config
    end
    
    protected
    
    def self.write_webserver_config(server_name, server_aliases)
      
      template_file = File.join(File.dirname(__FILE__), '..', '..', 'templates', 'nginx_v_host.erb')
      template = Erubis::Eruby.new(File.read(template_file))
      
      server_aliases ||= ''
      server_aliases = server_aliases.gsub(',', ' ')
      
      
      v_host_file = File.join(APP_CONFIG['v_host_config_dir'].split('/'), "#{server_name}.conf")
      v_host_config = template.result({
        :server_name => server_name,
        :routers => APP_CONFIG['routers'],
        :server_aliases => server_aliases
      })
      
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