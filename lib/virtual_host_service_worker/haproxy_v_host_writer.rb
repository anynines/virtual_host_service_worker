require 'erubis'
require 'fileutils'

module VirtualHostServiceWorker
  class HaproxyVHostWriter < VHostWriter

    def self.setup_v_host(payload)
      payload['server_name'] = payload['server_name'].downcase
      payload['server_aliases'] = payload['server_aliases'].downcase if payload['server_aliases']

      write_bundled_certificates(payload['server_name'],
                                 payload['ssl_ca_certificate'],
                                 payload['ssl_certificate'],
                                 payload['ssl_key'])

      write_certificate_list(payload['server_name'], payload['server_aliases'])

      reload_config
    end

    def self.delete_v_host(server_name)
      delete_certificate(server_name)
      delete_from_certificate_list(server_name)

      reload_config
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
          :ssl_certificate => cert,
          :ssl_ca_certificate => ca_cert,
          :ssl_key => ssl_key,
        }))
      end

    end

    def self.write_certificate_list(server_name, server_aliases)
      cert_list = "#{APP_CONFIG['haproxy_cert_list']}"
      pem_path = File.join(APP_CONFIG['haproxy_cert_dir'].split('/'), "#{server_name.gsub('*', 'wild')}.pem")

      shared_template_file = File.join(File.dirname(__FILE__), "..", "..", "templates", "haproxy_crt_list.erb")
      shared_template = Erubis::Eruby.new(File.read(shared_template_file))

      shared_config_file = File.join(cert_list)

      File.open(shared_config_file, 'a+') do |f|
        f.write(shared_template.result({
          :pem_path       => pem_path,
          :ssl_ciphers    => APP_CONFIG['haproxy_ssl_ciphers'],
          :server_names   => server_name,
        }))
        f.write "\n"
      end
    end

    def self.delete_certificate(server_name)
      cert_file = File.join(APP_CONFIG['haproxy_cert_dir'].split('/'), "#{server_name}.pem")

      execute_command("rm -f #{cert_file}")
    end

    def self.delete_from_certificate_list(server_name)
      cert_file = File.join(APP_CONFIG['haproxy_cert_dir'].split('/'), "#{server_name.downcase}.pem")

      cert_list = File.readlines(APP_CONFIG['haproxy_cert_list'])
      matches = cert_list.reject { |entry| entry.include?(cert_file) }

      File.open((APP_CONFIG['haproxy_cert_list'] ), 'w') do |f|
        matches.each do |entry|
          f.write entry
        end
      end

    end

    def self.reload_config
      execute_command("#{APP_CONFIG['haproxy_reload']}") if config_valid?
    end

    def self.config_valid?
      command = "#{APP_CONFIG['haproxy_command']} -f #{APP_CONFIG['haproxy_config']} -c"
      execute_command(command, 'Invalid haproxy configuration')
    end
  end
end