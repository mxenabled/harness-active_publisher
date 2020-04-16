require "spec_helper"

describe ::Harness::ActivePublisher do
  let(:collector) { ::Harness::NullCollector.new }

  before do
    ::Harness.config.queue = ::Harness::SyncQueue.new
    ::Harness.config.collector = collector
  end

  it "has a version number" do
    expect(Harness::ActivePublisher::VERSION).not_to be nil
  end

  describe "async_queue_size.active_publisher" do
    it "updates the queue size count" do
      expect(collector).to receive(:gauge).with("active_publisher.async_queue_size", 1000)
      ::ActiveSupport::Notifications.instrument "async_queue_size.active_publisher", 1000
    end
  end

  describe "message_dropped.active_publisher" do
    it "increments the message was dropped counter" do
      expect(collector).to receive(:increment).with("active_publisher.message_dropped")
      ::ActiveSupport::Notifications.instrument "message_dropped.active_publisher"
    end
  end

  describe "message_published.active_publisher" do
    it "increments the message was published counter" do
      expect(collector).to receive(:count).with("active_publisher.messages_published", 1)
      ::ActiveSupport::Notifications.instrument("message_published.active_publisher") {}
    end

    it "increments the messages was published counter by the number provided" do
      expect(collector).to receive(:count).with("active_publisher.messages_published", 1000)
      ::ActiveSupport::Notifications.instrument("message_published.active_publisher", :message_count => 1000) {}
    end

    it "increments the message was published counter with a specified route" do
      expect(collector).to receive(:count).with("active_publisher.messages_published.test-route", 1)
      ::ActiveSupport::Notifications.instrument("message_published.active_publisher", :route => "test.route") {}
    end

    it "records the publish latency" do
      stat = ""
      duration = 0
      expect(collector).to receive(:timing) do |the_stat, the_duration|
        stat = the_stat
        duration = the_duration
      end

      ::ActiveSupport::Notifications.instrument "message_published.active_publisher" do
        sleep 0.1
      end
      expect(stat).to eq("active_publisher.publish_latency")
      expect(duration).to be >= 0.1
    end
  end

  describe "wait_for_async_queue.active_publisher" do
    it "increments the message was dropped counter" do
      stat = ""
      duration = 0
      expect(collector).to receive(:timing) do |the_stat, the_duration|
        stat = the_stat
        duration = the_duration
      end

      ::ActiveSupport::Notifications.instrument "wait_for_async_queue.active_publisher" do
        sleep 0.1
      end
      expect(stat).to eq("active_publisher.waiting_for_async_queue")
      expect(duration).to be >= 0.1
    end
  end
end
