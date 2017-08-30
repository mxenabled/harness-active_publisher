require "harness/active_publisher/version"

::ActiveSupport::Notifications.subscribe "wait_for_async_queue.active_publisher" do |*args|
  event = ::ActiveSupport::Notifications::Event.new(*args)
  ::Harness.timing "active_publisher.waiting_for_async_queue", event.duration
end
