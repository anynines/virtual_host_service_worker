require 'json'

DaemonKit::Application.running! do |config|
end

DaemonKit::AMQP.run do |connection|
  connection.on_tcp_connection_loss do |connection, _settings|
    puts "--> detected connection lost"
    Honeybadger.notify("--> detected connection lost")
    connection.reconnect(false, 10)
  end

  connection.on_connection_interruption do |_conn|
    puts "--> detected connection interruption"
    Honeybadger.notify("--> detected connection interruption")
    EventMachine.stop
  end

  connection.on_error do |_conn, connection_close|
    Honeybadger.notify("--> Handling a connection-level exception.")
    puts "--------"
    puts "Handling a connection-level exception."
    puts "AMQP class id : #{connection_close.class_id}"
    puts "AMQP method id: #{connection_close.method_id}"
    puts "Status code   : #{connection_close.reply_code}"
    puts "Error message : #{connection_close.reply_text}"
    puts "--------"
    EventMachine.stop
  end

  channel = AMQP::Channel.new(connection)

  channel.on_connection_interruption do |ch|
    puts "--> Channel #{ch.id} detected connection interruption"
    Honeybadger.notify("--> Channel #{ch.id} detected connection interruption")
    EventMachine.stop
  end

  exchange = channel.fanout(APP_CONFIG['amqp_channel'], :durable => true)

  exchange.on_connection_interruption do |ex|
    puts "--> Exchange #{ex.name} detected connection interruption"
    Honeybadger.notify("--> Exchange #{ex.name} detected connection interruption")
    EventMachine.stop
  end

  worker_queue = channel.queue(APP_CONFIG['queue_id'], :durable => true)

  worker_queue.on_connection_interruption do |q|
    puts "--> qeue #{q.name} detected connection interruption"
    Honeybadger.notify("--> qeue #{q.name} detected connection interruption")
    EventMachine.stop
  end

  worker_queue.bind(exchange).subscribe do |payload|
    VirtualHostServiceWorker::AmqpDispatcher.dispatch(JSON.parse(payload))
  end
end
