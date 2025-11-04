##### Requirement's #####
require 'bundler/capistrano'
require 'capistrano/ext/multistage'
# require "whenever/capistrano"

##### Stages #####
set :stages, %w(production)

##### Constant variables #####
set :application, "ssl_gateway"
set :deploy_to,   "/var/www/#{application}"
set :use_sudo, false
set :user, "deploy"

##### Default variables #####
set :keep_releases, 10

##### Repository Settings #####
set :scm,        :git
set :repository, "git@github.com:avarteqgmbh/virtual_host_service_worker.git"

##### Additional Settings #####
# set :deploy_via, :remote_cache
set :ssh_options, { :forward_agent => true }
default_run_options[:pty] = true

##### Overwritten and changed default capistrano tasks #####
namespace :deploy do
  task :start, :roles => :app, :except => { :no_release => true } do
    run "cd #{current_path} && DAEMON_ENV=#{env} bundle exec bin/virtual_host_service_worker --pidfile #{pidfile} start"
  end

  task :stop, :roles => :app, :except => { :no_release => true } do
    run "cd #{current_path} && DAEMON_ENV=#{env} bundle exec bin/virtual_host_service_worker --pidfile #{pidfile} stop"
  end

  task :restart, :roles => :app, :except => { :no_release => true } do
    stop
    start
  end

  desc "Additional Symlinks"
  task :additional_symlink, :roles => :app do
    run "ln -nfs #{shared_path}/config/amqp.yml #{release_path}/config/amqp.yml"
    run "ln -nfs #{shared_path}/config/application.yml #{release_path}/config/application.yml"
  end
end

##### After and Before Tasks #####
before "deploy:restart", "deploy:additional_symlink"
after "deploy:restart", "deploy:cleanup"

# require 'config/boot'
# require 'airbrake/capistrano'

require './config/boot'
