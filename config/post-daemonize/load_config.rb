require 'yaml'

DAEMON_ENV = 'development' unless defined?( DAEMON_ENV )

APP_CONFIG = YAML.load_file(File.join(File.dirname(__FILE__), '..', 'application.yml'))[DAEMON_ENV]