DAEMON_ENV = 'test' unless defined?( DAEMON_ENV )

require 'rspec'
require 'mocha/setup'

require File.dirname(__FILE__) + '/../config/environment'
DaemonKit::Application.running!

RSpec.configure do |config|

  config.color_enabled = true
  config.formatter = :documentation
  config.mock_with :mocha

end
