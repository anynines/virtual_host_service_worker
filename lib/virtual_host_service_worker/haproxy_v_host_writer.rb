require 'erubis'
require 'fileutils'

module VirtualHostServiceWorker

  class HaproxyVHostWriter < VHostWriter

    def self.setup_v_host(payload)
      pp payload
      payload['server_name'] = payload['server_name'].downcase
      payload['server_aliases'] = payload['server_aliases'].downcase if payload['server_aliases']

      write_bundled_certificates(payload['server_name'],
                                 payload['ssl_ca_certificate'],
                                 payload['ssl_certificate'],
                                 payload['ssl_key'])

      reload_config
    end

    def self.delete_v_host(server_name)
    end

    def self.write_shared_webserver_config_files
    end

    protected

    def self.write_bundled_certificates(server_name, ca_cert, cert, ssl_key)
      pem_file = File.join(APP_CONFIG['haproxy_cert_dir'].split('/'), "#{server_name.gsub('*', 'wild')}.pem")

      FileUtils.rm(pem_file) if File.exist?(pem_file)

      shared_template_file = File.join(File.dirname(__FILE__), "..", "..", "templates", "haproxy_cert_x_pem.erb")
      shared_template = Erubis::Eruby.new(File.read(shared_template_file))

      shared_config_file = File.join(pem_file)
      File.open(shared_config_file, 'w') do |f|
        f.write(shared_template.result({
          :ssl_ca_certificate => ca_cert,
          :ssl_certificate => cert,
          :ssl_key => ssl_key,
        }))
      end
    end

    def self.write_certificate_list()

    end

    def self.reload_config
      execute_command("#{APP_CONFIG['haproxy_command']}") if config_valid?
    end

    def self.config_valid?
      command = "#{APP_CONFIG['haproxy_command']} -f #{APP_CONFIG['haproxy_config']} -c"
      execute_command(command, 'Invalid haproxy configuration')
    end
    
  end
end
