DAEMON_ENV = 'test' unless defined?( DAEMON_ENV )

require 'rspec'
require 'mocha'
require 'fileutils'

require File.dirname(__FILE__) + '/../config/environment'

# NGINX
FileUtils.mkdir_p('tmp/cert_dir')
FileUtils.mkdir_p('tmp/v_host_config_dir')
FileUtils.mkdir_p('tmp/v_host_link_dir')

# HAProxy
FileUtils.mkdir_p('tmp/haproxy/certificates/')
FileUtils.mkdir_p('tmp/haproxy/config')

APP_CONFIG = {
  "amqp_channel"      => "channel",
  "queue_id"          => 123,
  "cert_dir"          => File.expand_path('../../tmp/cert_dir', __FILE__) + '/',
  "v_host_config_dir" => File.expand_path('../../tmp/v_host_config_dir', __FILE__) + '/',
  "v_host_link_dir"   => File.expand_path('../../tmp/v_host_link_dir', __FILE__) + '/',
  "webserver_config"  => File.expand_path('../../tmp/webserver_config', __FILE__),
  "shared_config"     => File.expand_path('../../tmp/shared_config',__FILE__),
  "upstream_config"   => File.expand_path('../../tmp/upstream_config', __FILE__),
  "nginx_command"     => File.expand_path('../../spec/support/nginx_dummy', __FILE__),
  "routers"           => [],

  "haproxy_command"         => File.expand_path('../../spec/support/haproxy_dummy', __FILE__),
  "haproxy_reload"          => File.expand_path('../../spec/support/haproxy_dummy', __FILE__),
  "haproxy_dir"             => File.expand_path('../../tmp/haproxy/', __FILE__),
  "haproxy_config"          => File.expand_path('../../tmp/haproxy/config/haproxy.cfg', __FILE__),
  "haproxy_cert_dir"        => File.expand_path('../../tmp/haproxy/certificates', __FILE__) + '/',
  "haproxy_cert_list"       => File.expand_path('../../tmp/haproxy/haproxy-certificate-list', __FILE__),
  "haproxy_ssl_ciphers"     => "[alpn h2 ssl-min-ver TLSv1.2]",
}

DaemonKit::Application.running!

RSpec.configure do |config|
  config.color = true
  config.mock_with :mocha
end
