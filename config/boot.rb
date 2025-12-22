# Don't change this file!
# Configure your daemon in config/environment.rb

DAEMON_ROOT = "#{__dir__}/.." unless defined?(DAEMON_ROOT)

require 'rubygems'
require 'bundler/setup'

module DaemonKit
  class << self
    def boot!
      return if booted?

      pick_boot.run
    end

    def booted?
      defined? DaemonKit::Initializer
    end

    def pick_boot
      (vendor_kit? ? VendorBoot : GemBoot).new
    end

    def vendor_kit?
      File.exist?("#{DAEMON_ROOT}/vendor/daemon-kit")
    end
  end

  class Boot
    def run
      load_initializer
      DaemonKit::Initializer.run
    end
  end

  class VendorBoot < Boot
    def load_initializer
      require "#{DAEMON_ROOT}/vendor/daemon-kit/lib/daemon_kit/initializer"
    end
  end

  class GemBoot < Boot
    def load_initializer
      require 'rubygems' unless defined?(::Gem)
      gem 'daemon-kit'
      require 'daemon_kit/initializer'
    rescue ::Gem::LoadError
      msg = <<~EOF

        You are missing the daemon-kit gem. Please install the following gem:

        sudo gem install daemon-kit

      EOF
      warn msg
      exit 1
    end
  end
end

DaemonKit.boot!
