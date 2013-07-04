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
      
      if config_valid?
        reload_config
      else
        # airbreak
      end
    end
    
    protected
    
    def self.write_webserver_config(server_name, server_aliases)
      
      template_file = File.join(File.dirname(__FILE__), '..', '..', 'templates', 'nginx_v_host.conf.erb')
      template = Erubis::Eruby.new(File.read(template_file))
      
      server_aliases ||= ''
      server_aliases = server_aliases.gsub(',', ' ')
      
      
      v_host_file = File.join(APP_CONFIG['v_host_config_dir'].split('/'), "#{server_name}.conf")
      v_host_config = template.result({
        :server_name => server_name,
        :server_aliases => server_aliases,
        :path_to_ssl_files => APP_CONFIG['cert_dir']
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
    
    def self.write_shared_webserver_config_files
      shared_template_file = File.join(File.dirname(__FILE__), '..', '..', 'templates', 'nginx_shared.conf.erb')
      shared_template = Erubis::Eruby.new(File.read(shared_template_file))
      
      shared_config_file = File.join(APP_CONFIG['shared_config'].split('/'))
      File.open(shared_config_file, 'w') do |f|
        f.write(shared_template.result)
      end
      
      upstream_template_file = File.join(File.dirname(__FILE__), '..', '..', 'templates', 'nginx_cf_routers.conf.erb')
      upstream_template = Erubis::Eruby.new(File.read(upstream_template_file))
      
      upstream_config_file = File.join(APP_CONFIG['upstream_config'].split('/'))
      File.open(upstream_config_file, 'w') do |f|
        f.write(upstream_template.result({
          :routers => APP_CONFIG['routers']
        }))
      end
      
      reload_config if config_valid?
    end
    
    def self.reload_config
      `sudo nginx -s reload`
    end
    
    def self.config_valid?
      # see rh-web-server-service
      out = `sudo nginx -t -c #{APP_CONFIG['webserver_config']} && echo "nginx config is valid!!"`
      out.include?("nginx config is valid!!")
    end
    
  end
end