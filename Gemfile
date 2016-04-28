# If you need to 'vendor your gems' for deploying your daemons, bundler is a
# great option. Update this Gemfile with any additional dependencies and run
# 'bundle install' to get them all installed. Daemon-kit's capistrano
# deployment will ensure that the bundle required by your daemon is properly
# installed.
#
# For more information on bundler, please visit http://gembundler.com

source 'https://rubygems.org'

gem 'daemon-kit'
gem 'safely'
gem 'amqp'
gem 'erubis'
gem 'honeybadger'

group :development, :test do
  gem 'rake'
  gem 'rspec'
  gem 'mocha'
end
