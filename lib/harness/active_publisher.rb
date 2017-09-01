require "harness/active_publisher/version"

::ActiveSupport::Notifications.subscribe "async_queue_size.active_publisher" do |async_queue_size|
  ::Harness.counter "active_publisher.async_queue_size", async_queue_size
end

::ActiveSupport::Notifications.subscribe "message_dropped.active_publisher" do
  ::Harness.increment "active_publisher.message_dropped"
end

::ActiveSupport::Notifications.subscribe "wait_for_async_queue.active_publisher" do |*args|
  event = ::ActiveSupport::Notifications::Event.new(*args)
  ::Harness.timing "active_publisher.waiting_for_async_queue", event.duration
end
