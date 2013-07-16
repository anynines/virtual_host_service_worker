role :app, "109.234.107.6", :primary => true
role :web, "109.234.107.6", :primary => true

set :user, "deploy"
set :use_sudo, true
set :env, "production"
set :pidfile, "tmp/virtual_host_service_worker.pid"
set :branch, fetch(:branch, "master")