require 'yaml'

APP_CONFIG = YAML.load_file(File.join(File.dirname(__FILE__), '..', 'application.yml'))