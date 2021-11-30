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

  describe "connection_blocked.active_publisher" do
    before { ::ENV["SERVICE_NAME"] = "my_app" }
    after { ::ENV.delete("SERVICE_NAME") }

    it "increments the connection blocked count" do
      expect(collector).to receive(:increment).with("active_publisher.my_app.connection.blocked.low_on_memory")
      ::ActiveSupport::Notifications.instrument("connection_blocked.active_publisher", :reason => "low on memory")
    end

    it "uses a default value when reason is nil" do
      expect(collector).to receive(:increment).with("active_publisher.my_app.connection.blocked.reason_for_blocking_is_missing")
      ::ActiveSupport::Notifications.instrument("connection_blocked.active_publisher", :reason => nil)
    end
  end

  describe "connection_unblocked.active_publisher" do
    it "increments the connection unblocked count" do
      expect(collector).to receive(:increment).with("active_publisher.connection.unblocked")
      ::ActiveSupport::Notifications.instrument("connection_unblocked.active_publisher")
    end
  end

  describe "redis_async_queue_size.active_publisher" do
    it "updates the queue size count" do
      expect(collector).to receive(:gauge).with("active_publisher.redis_async_queue_size", 1000)
      ::ActiveSupport::Notifications.instrument "redis_async_queue_size.active_publisher", 1000
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

  describe "publishes_confirmed.active_publisher" do
    it "incremenets the publishes_confirmed metric" do
      expect(collector).to receive(:increment).with("active_publisher.publishes_confirmed")
      ::ActiveSupport::Notifications.instrument("publishes_confirmed.active_publisher") {}
    end

    it "records the publishes_confirmed latency" do
      stat = ""
      duration = 0
      expect(collector).to receive(:timing) do |the_stat, the_duration|
        stat = the_stat
        duration = the_duration
      end

      ::ActiveSupport::Notifications.instrument "publishes_confirmed.active_publisher" do
        sleep 0.1
      end
      expect(stat).to eq("active_publisher.publishes_confirmed_latency")
      expect(duration).to be >= 0.1
    end
  end
end
