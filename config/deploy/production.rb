role :app, "5.22.148.133", :primary => true
role :web, "5.22.148.133", :primary => true

set :user, "deploy"
set :env, "production"
set :pidfile, "tmp/virtual_host_service_worker.pid"
set :branch, fetch(:branch, "master")