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

      VirtualHostServiceWorker::AmqpDispatcher.push_reload_to_amqp
    end

    def self.delete_v_host(server_name)
      delete_certificate(server_name)
      delete_from_certificate_list(server_name)

      VirtualHostServiceWorker::AmqpDispatcher.push_reload_to_amqp
    end

    def self.write_bundled_certificates(server_name, ca_cert, cert, ssl_key)
      pem_path = build_pem_path(server_name)
      FileUtils.rm_f(pem_path)

      File.open(pem_path, 'w') do |f|
        f.write(pem_template.result({
                                      ssl_certificate: cert,
                                      ssl_ca_certificate: ca_cert,
                                      ssl_key:
                                    }))
      end
    end

    def self.write_certificate_list(server_name, server_aliases)
      server_names = [server_name]
      server_names += server_aliases.split(',') if server_aliases
      server_names = server_names.flatten.compact * ' '

      File.open(cert_list_path, 'a+') do |f|
        f.write(cert_list_template.result({
                                            pem_path: build_pem_path(server_name),
                                            ssl_ciphers: APP_CONFIG['haproxy_ssl_ciphers'],
                                            server_names:
                                          }))
        f.write "\n"
      end
    end

    def self.delete_certificate(server_name)
      execute_command("rm -f #{build_pem_path(server_name)}")
    end

    def self.delete_from_certificate_list(server_name)
      pem_path = build_pem_path(server_name)

      cert_list = File.readlines(cert_list_path)

      new_cert_list = cert_list.reject do |entry|
        entry.include?(pem_path)
      end.join

      File.write(cert_list_path, new_cert_list, mode: 'w')
    end

    def self.reload_config
      execute_command("#{APP_CONFIG['haproxy_reload']}") if config_valid?
    end

    def self.haproxy_instance_limit_reached?
      currentInstances = `(ps aux | grep haproxy | wc -l)`

      result = ((currentInstances.strip.to_i(-1)) >= APP_CONFIG['haproxy_reload_max_instances'].to_i)

      return result
    end

    def self.config_valid?
      command = "#{APP_CONFIG['haproxy_command']} -f #{APP_CONFIG['haproxy_config']} -c"
      execute_command(command, 'Invalid haproxy configuration')
    end

    def self.build_pem_path(server_name)
      File.join(APP_CONFIG['haproxy_cert_dir'].split('/'), "#{sanitize_file_name(server_name)}.pem")
    end

    def self.sanitize_file_name(server_name)
      server_name.downcase.gsub('*', 'wild')
    end

    def self.cert_list_path
      APP_CONFIG['haproxy_cert_list']
    end

    def self.cert_list_template
      Erubis::Eruby.new(File.read(cert_list_template_path))
    end

    def self.cert_list_template_path
      File.join(File.dirname(__FILE__), '..', '..', 'templates', 'haproxy_crt_list.erb')
    end

    def self.pem_template
      Erubis::Eruby.new(
        File.read(pem_template_path)
      )
    end

    def self.pem_template_path
      File.join(File.dirname(__FILE__), '..', '..', 'templates', 'haproxy_cert_x_pem.erb')
    end
  end
end
