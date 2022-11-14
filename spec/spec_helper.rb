DAEMON_ENV = 'test' unless defined?( DAEMON_ENV )

require 'rspec'
require 'mocha/setup'
require 'fileutils'

require File.dirname(__FILE__) + '/../config/environment'

FileUtils.mkdir_p('tmp/cert_dir')
FileUtils.mkdir_p('tmp/v_host_config_dir')
FileUtils.mkdir_p('tmp/v_host_link_dir')

APP_CONFIG = {
  "amqp_channel"      => "channel",
  "queue_id"          =>  123,
  "cert_dir"          => File.expand_path('../../tmp/cert_dir', __FILE__) + '/',
  "v_host_config_dir" => File.expand_path('../../tmp/v_host_config_dir', __FILE__) + '/',
  "v_host_link_dir"   => File.expand_path('../../tmp/v_host_link_dir', __FILE__) + '/',
  "webserver_config"  => File.expand_path('../../tmp/webserver_config', __FILE__),
  "shared_config"     => File.expand_path('../../tmp/shared_config',__FILE__),
  "upstream_config"   => File.expand_path('../../tmp/upstream_config', __FILE__),
  "nginx_command"     => File.expand_path('../../spec/support/nginx_dummy', __FILE__),
  "routers"           => [],
}

DaemonKit::Application.running!

RSpec.configure do |config|
  config.color = true
  config.mock_with :mocha
end
