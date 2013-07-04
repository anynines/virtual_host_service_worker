require 'json'

DaemonKit::Application.running! do |config|

end

DaemonKit::AMQP.run do |connection|
  channel  = AMQP::Channel.new(connection)
  exchange = channel.fanout(APP_CONFIG['amqp_channel'])

  channel.queue(APP_CONFIG['queue_id']).bind(exchange).subscribe do |payload|
    VirtualHostServiceWorker::AmqpDispatcher.dispatch(JSON.parse(payload))
  end
end
