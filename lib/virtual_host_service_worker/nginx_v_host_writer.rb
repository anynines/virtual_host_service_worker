require 'erubis'
require 'fileutils'

module VirtualHostServiceWorker
  
  ##
  # This class provides methods to add virtual hosts to an nginx configuration.
  # Public interface:
  #   self.setup_v_hos
  #   self.write_shared_webserver_config_files
  #
  class NginxVHostWriter < VHostWriter
    
    ##
    # Adds a new virtual hosts configured with a ssl certificate to the nginx config.
    # The virtual host information is passed as hash to the method. The hash must contain the
    # following keys:
    # server_name: The name of the virtual host (the domain that should be protected by the certificate)
    # server_aliases: (optional) In case the certificate is a wildcard certificate some subdomains could
    #   be specified by this key (as comma separated list).
    # ssl_ca_certificate: The certificate of the certification authority.
    # ssl_certificate: The certificate belonging to the domain (server_name).
    # ssl_key: The private key for the ssl certificate
    #
    def self.setup_v_host(payload)
      payload['server_name'] = payload['server_name'].downcase
      payload['server_aliases'] = payload['server_aliases'].downcase if payload['server_aliases']
      
      write_bundled_certificates(payload['server_name'],
                                 payload['ssl_ca_certificate'],
                                 payload['ssl_certificate'])
      
      write_ssl_key(payload['server_name'], payload['ssl_key'])
      
      write_webserver_config(payload['server_name'], payload['server_aliases'])
      
      link_webserver_config(payload['server_name'])
      
      reload_config
    end
    
    ##
    # Deletes the ssl certificates and the nginx config from a virutal host.
    #
    def self.delete_v_host(server_name)
      v_host_file = File.join(APP_CONFIG['v_host_config_dir'].split('/'), "#{server_name}.conf")
      v_host_link = File.join(APP_CONFIG['v_host_link_dir'].split('/'), "#{server_name}.conf")
      key_file    = File.join(APP_CONFIG['cert_dir'].split('.'), "#{server_name}.key")
      pem_file    = File.join(APP_CONFIG['cert_dir'].split('/'), "#{server_name}.pem")
      
      execute_command("rm -f #{v_host_file}")
      execute_command("rm -f #{key_file}")
      execute_command("rm -f #{pem_file}")
      execute_command("rm -f #{v_host_link}") if APP_CONFIG['v_host_link_dir'] 
      
      reload_config
    end
    
    ##
    # Writes the common cofig files which are shared by all virtual hosts.
    # If the files already exists they would be overridden so that the values form
    # the config/application.yml will be applied. This methods should be called on
    # every deamon start/restart.
    #
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
      
      reload_config
    end
    
    protected
    
    ##
    # Write the actual virtual host configuration pointing to the certificate fiels. 
    #
    def self.write_webserver_config(server_name, server_aliases)
      
      template_file = File.join(File.dirname(__FILE__), '..', '..', 'templates', 'nginx_v_host.conf.erb')
      template = Erubis::Eruby.new(File.read(template_file))
      
      server_aliases ||= ''
      server_aliases = server_aliases.gsub(',', ' ')
      
      
      v_host_file = File.join(APP_CONFIG['v_host_config_dir'].split('/'), "#{server_name.gsub('*', 'wild')}.conf")
      v_host_config = template.result({
        :server_name => server_name,
        :server_aliases => server_aliases,
        :path_to_ssl_files => APP_CONFIG['cert_dir']
      })
      
      File.open(v_host_file, 'w') do |f|
        f.write(v_host_config)
      end
      
    end

    ##
    # Links the webserver config created in self.write_webserver_config to an
    # other directory spezified in the APP_CONFIG
    # e.g.: Write the config in the sites-available directory and link it in the sites-enabled directory
    #
    def self.link_webserver_config(server_name)
      return if (not APP_CONFIG['v_host_link_dir']) or APP_CONFIG['v_host_link_dir'] == ""

      v_host_file = File.join(APP_CONFIG['v_host_config_dir'].split('/'), "#{server_name.gsub('*', 'wild')}.conf")
      v_host_link = File.join(APP_CONFIG['v_host_link_dir'].split('/'), "#{server_name.gsub('*', 'wild')}.conf")
      execute_command("ln -s #{v_host_file} #{v_host_link}")
    end
    
    ##
    # Wirte the ssl key file to directory specified by the application config (config/application.yml).
    #
    def self.write_ssl_key(server_name, key)
      key_file = File.join(APP_CONFIG['cert_dir'].split('/'), server_name.gsub('*', 'wild'), "#{server_name.gsub('*', 'wild')}.key")
      FileUtils.mkdir_p(File.dirname(key_file))      

      File.open(key_file, 'w') do |f|
        f.write(key)
      end
    end
    
    ##
    # Bundles the ca certificate and the ssl certificate into one pem file and write it into the
    # directory specified by the application config (config/application.yml).
    #
    def self.write_bundled_certificates(server_name, ca_cert, cert)
      pem_file = File.join(APP_CONFIG['cert_dir'].split('/'), server_name.gsub('*', 'wild'), "#{server_name.gsub('*', 'wild')}.pem")
      FileUtils.mkdir_p(File.dirname(pem_file))

      File.open(pem_file, 'w') do |f|
        f.write(cert)
        f.write("\n")
        f.write(ca_cert)
      end
    end
    
    ##
    # Couses nginx to realod the created configuration.
    #
    def self.reload_config
      execute_command("#{APP_CONFIG['nginx_command']} -s reload") if config_valid?
    end
    
    ##
    # Checks if the created nginx cofiguration is valid.
    #
    def self.config_valid?
      command = "#{APP_CONFIG['nginx_command']} -t -c #{APP_CONFIG['webserver_config']}"  
      execute_command(command, 'Invalid nginx configuration')
    end
    
  end
end