require "harness/active_publisher/version"

require "harness"
require "active_support"

DROPPED_METRIC    = ["active_publisher", ENV["SERVICE_NAME"], "message_dropped"].reject(&:nil?).join(".").freeze
LATENCY_METRIC    = ["active_publisher", ENV["SERVICE_NAME"], "publish_latency"].reject(&:nil?).join(".").freeze
PUBLISHED_METRIC  = ["active_publisher", ENV["SERVICE_NAME"], "messages_published"].reject(&:nil?).join(".").freeze
QUEUE_SIZE_METRIC = ["active_publisher", ENV["SERVICE_NAME"], "async_queue_size"].reject(&:nil?).join(".").freeze
WAIT_METRIC       = ["active_publisher", ENV["SERVICE_NAME"], "waiting_for_async_queue"].reject(&:nil?).join(".").freeze

::ActiveSupport::Notifications.subscribe "async_queue_size.active_publisher" do |_, _, _, _, async_queue_size|
  ::Harness.gauge QUEUE_SIZE_METRIC, async_queue_size
end

::ActiveSupport::Notifications.subscribe "message_dropped.active_publisher" do
  ::Harness.increment DROPPED_METRIC
end

::ActiveSupport::Notifications.subscribe "message_published.active_publisher" do |*args|
  event = ::ActiveSupport::Notifications::Event.new(*args)
  message_count = event.payload.fetch(:message_count, 1)
  ::Harness.count PUBLISHED_METRIC, message_count
  ::Harness.timing LATENCY_METRIC, event.duration
end

::ActiveSupport::Notifications.subscribe "wait_for_async_queue.active_publisher" do |*args|
  event = ::ActiveSupport::Notifications::Event.new(*args)
  ::Harness.timing WAIT_METRIC, event.duration
end
