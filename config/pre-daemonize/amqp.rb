begin
  require 'amqp'
rescue LoadError
  warn "Missing amqp gem. Please run 'bundle install'."
  exit 1
end
