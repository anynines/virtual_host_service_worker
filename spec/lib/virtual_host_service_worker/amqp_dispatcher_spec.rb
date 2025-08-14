require 'spec_helper'

RSpec.describe VirtualHostServiceWorker::AmqpDispatcher do
  describe '.push_reload_to_amqp' do
    let(:connection) { double('connection') }
    let(:channel) { double('channel') }
    let(:exchange) { double('exchange') }
    let(:server_name) { 'test_name' }

    before do 
      # stub_const('APP_CONFIG', {
      #   'amqp' => { host: 'localhost' },
      #   'amqp_channel' => 'test_channel'
      # })

      allow(described_class).to receive(:server_name).and_return(server_name)
      
      allow(AMQP).to receive(:start).and_yield(connection)
      allow(AMQP:Channel).to receive(:new).with(connection).and_return(channel)
      allow(channel).to receive(:fanout).with('test_channel', durable: true).and_return(exchange)

      allow(exchange).to receive(:publish).and_yield
      allow(connection).to receive(:close).and_yield
      allow(EventMachine).to receive(:stop)
    end

    it 'start with correct config' do
      described_class.push_reload_to_amqp
      expect(AMQP).to have_received(:start).with(APP_CONFIG['amqp'])
    end

    it 'publishes reload payload' do
      described_class.push_reload_to_amqp
      expected_paylad = {
        action: 'reload',
        server_name: server_name
    }.to_json

    expect(exchange).to have_received(:publish).with(expected_payload)
    end
  end
end