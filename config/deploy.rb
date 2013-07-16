##### Requirement's #####
require 'bundler/capistrano'
require 'capistrano/ext/multistage'
#require "whenever/capistrano"

#### Use the asset-pipeline
load 'deploy/assets'

##### Stages #####
set :stages, %w(production)

##### Constant variables #####
set :application, "ssl_gateway"
set :deploy_to,   "/var/www/#{application}"
set :user, "deploy"
set :use_sudo, true

##### Default variables #####
set :keep_releases, 10

##### Repository Settings #####
set :scm,        :git
set :repository, "git@github.com:avarteqgmbh/virtual_host_service_worker.git"

##### Additional Settings #####
#set :deploy_via, :remote_cache
set :ssh_options, { :forward_agent => true }
ssh_options[:keys] = [File.join(ENV["HOME"], ".ssh", "id_dsa")]
default_run_options[:pty] = true

##### Overwritten and changed default capistrano tasks #####
namespace :deploy do

  task :start, :roles => :app, :except => { :no_release => true } do
    run "cd #{current_path} && sudo DAEMON_ENV=#{env} bin/virtual_host_service_worker --pidfile #{pidfile} start"
  end

  task :stop, :roles => :app, :except => { :no_release => true } do
    run "cd #{current_path} && sudo bin/virtual_host_service_worker --pidfile #{pidfile} stop"
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
before "deploy:additional_symlink"
after "deploy:restart", "deploy:cleanup"

#require 'config/boot'
#require 'airbrake/capistrano'

require './config/boot'

