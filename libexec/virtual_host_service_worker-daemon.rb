# Generated amqp daemon

# Do your post daemonization configuration here
# At minimum you need just the first line (without the block), or a lot
# of strange things might start happening...
DaemonKit::Application.running! do |config|
  # Trap signals with blocks or procs
  # config.trap( 'INT' ) do
  #   # do something clever
  # end
  # config.trap( 'TERM', Proc.new { puts 'Going down' } )
end

DaemonKit::AMQP.run do |connection|
  channel  = AMQP::Channel.new(connection)
  exchange = channel.fanout('virtual_host_jobs')
	
  channel.queue("worker1").bind(exchange).subscribe do |payload|
    puts payload
    puts "--"
  end
end
