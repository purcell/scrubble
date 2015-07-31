require 'thread' # <- a reliable sign of ensuing flaky hackery

module PubSub

  def self.publish(channel_name, thing)
    ensure_channel(channel_name).publish(thing)
  end

  def self.subscribe(channel_name, &block)
    ensure_channel(channel_name).subscribe(&block)
  end

  private

  CHANNELS = {}

  def self.ensure_channel(channel_name)
    CHANNELS[channel_name] ||= Channel.new(channel_name)
  end

  class Channel
    def initialize(name)
      @listeners = []
    end

    def publish(thing)
      Rails.logger.debug("Publishing #{thing} to #{@listeners.size} subscribers")
      @listeners.map do |listener|
        listener << thing
      end
      nil
    end

    def subscribe(&block)
      queue = Queue.new
      @listeners << queue
      Subscription.new(queue, &block).tap do |sub|
        Thread.new do
          sub.run(&block)
        end
      end
    end

    private

    class Subscription
      def initialize(queue, &callback)
        @queue = queue
        @callback = callback
      end

      def run
        while (thing = @queue.pop) != STOP
          begin
            @callback.call(thing)
          rescue
            Rails.logger.warn("Listener failed: #{$!}:#{$!.backtrace.join("\n")}")
          end
        end
      end

      ## TODO: this leaves queues sitting around
      def cancel
        @queue.push(STOP)
      end

      private

      STOP = (Class.new).new
    end
  end
end
