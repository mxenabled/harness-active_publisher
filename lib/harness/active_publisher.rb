require "harness/active_publisher/version"

require "harness"
require "active_support"

module Harness
  module ActivePublisher
    DROPPED_METRIC          = ["active_publisher", ENV["SERVICE_NAME"], "message_dropped"].reject(&:nil?).join(".").freeze
    LATENCY_METRIC          = ["active_publisher", ENV["SERVICE_NAME"], "publish_latency"].reject(&:nil?).join(".").freeze
    PUBLISHED_METRIC        = ["active_publisher", ENV["SERVICE_NAME"], "messages_published"].reject(&:nil?).join(".").freeze
    QUEUE_SIZE_METRIC       = ["active_publisher", ENV["SERVICE_NAME"], "async_queue_size"].reject(&:nil?).join(".").freeze
    REDIS_QUEUE_SIZE_METRIC = ["active_publisher", ENV["SERVICE_NAME"], "redis_async_queue_size"].reject(&:nil?).join(".").freeze
    WAIT_METRIC             = ["active_publisher", ENV["SERVICE_NAME"], "waiting_for_async_queue"].reject(&:nil?).join(".").freeze
    UNBLOCKED_METRIC        = ["active_publisher", ENV["SERVICE_NAME"], "connection", "unblocked"].reject(&:nil?).join(".").freeze

    ::ActiveSupport::Notifications.subscribe "async_queue_size.active_publisher" do |_, _, _, _, async_queue_size|
      ::Harness.gauge QUEUE_SIZE_METRIC, async_queue_size
    end

    ::ActiveSupport::Notifications.subscribe "connection_blocked.active_publisher" do |_, _, _, _, params|
      reason = params.fetch(:reason)
      blocked_metric = ["active_publisher", ENV["SERVICE_NAME"], "connection", "blocked", reason.gsub(/\W/, "_")].
        reject(&:nil?).join(".")

      ::Harness.increment blocked_metric
    end

    ::ActiveSupport::Notifications.subscribe "connection_unblocked.active_publisher" do
      ::Harness.increment UNBLOCKED_METRIC
    end

    ::ActiveSupport::Notifications.subscribe "redis_async_queue_size.active_publisher" do |_, _, _, _, redis_async_queue_size|
      ::Harness.gauge REDIS_QUEUE_SIZE_METRIC, redis_async_queue_size
    end

    ::ActiveSupport::Notifications.subscribe "message_dropped.active_publisher" do
      ::Harness.increment DROPPED_METRIC
    end

    ::ActiveSupport::Notifications.subscribe "message_published.active_publisher" do |*args|
      event = ::ActiveSupport::Notifications::Event.new(*args)
      route = event.payload.fetch(:route, "")
      route = ".#{route.gsub('.', '-')}" unless route.empty?
      message_count = event.payload.fetch(:message_count, 1)
      ::Harness.count PUBLISHED_METRIC + route, message_count
      ::Harness.timing LATENCY_METRIC, event.duration
    end

    ::ActiveSupport::Notifications.subscribe "wait_for_async_queue.active_publisher" do |*args|
      event = ::ActiveSupport::Notifications::Event.new(*args)
      ::Harness.timing WAIT_METRIC, event.duration
    end
  end
end
