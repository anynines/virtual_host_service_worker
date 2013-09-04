require 'yaml'
require 'honeybadger'

DAEMON_ENV = 'development' unless defined?( DAEMON_ENV )
APP_CONFIG = YAML.load_file(File.join(File.dirname(__FILE__), '..', 'application.yml'))[DAEMON_ENV]

if APP_CONFIG['honeybadger_api_key']
  Honeybadger.configure do |config|
    config.api_key = APP_CONFIG['honeybadger_api_key']
  end
end
