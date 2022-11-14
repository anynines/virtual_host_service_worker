DAEMON_ENV = 'test' unless defined?( DAEMON_ENV )

require 'rspec'
require 'mocha/setup'
require 'fileutils'

require File.dirname(__FILE__) + '/../config/environment'

FileUtils.mkdir_p('tmp/cert_dir')
FileUtils.mkdir_p('tmp/v_host_config_dir')

APP_CONFIG = {
  "amqp_channel"      => "channel",
  "queue_id"          =>  123,
  "cert_dir"          => 'tmp/cert_dir',
  "v_host_config_dir" => 'tmp/v_host_config_dir',
  "webserver_config"  => 'tmp/webserver_config',
  "shared_config"     => 'tmp/shared_config',
  "upstream_config"   => 'tmp/upstream_config',
  "nginx_command"     => 'spec/support/nginx_dummy',
  "routers"           => [],
}

DaemonKit::Application.running!

RSpec.configure do |config|
  config.mock_with :mocha
end
