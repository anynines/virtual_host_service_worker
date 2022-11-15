require 'erubis'
require 'fileutils'

module VirtualHostServiceWorker

  class HaProxyVHostWriter < VHostWriter

    def self.setup_v_host(payload)
    end

    def self.delete_v_host(server_name)
    end

    def self.write_shared_webserver_config_files
    end

    protected

    def self.write_webserver_config(server_name, server_aliases)
    end

    def self.link_webserver_config(server_name)
    end

    def self.write_ssl_key(server_name, key)
    end

    def self.write_bundled_certificates(server_name, ca_cert, cert)
    end

    def self.reload_config
    end

    def self.config_valid?
    end
    
  end
end
