require 'rpi_gpio/rpi_gpio'
require 'epoll'

module RPi
  module GPIO
    def watch(channel, on:, bounce_time: nil, &block) 
      gpio = RPi::GPIO.get_gpio_number(channel)
      RPi::GPIO.ensure_gpio_input(gpio)
      edge = on.to_sym
      if edge != :rising && edge != :falling && edge != :both
        raise ArgumentError, "invalid `on` value; must be 'rising', 'falling', or 'both'"
      end
      if bounce_time <= 0
        raise ArgumentError, '`bounce_time` must be greater than 0'
      end
      RPi::GPIO.add_edge_detect(gpio, edge, bounce_time)
      RPi::GPIO.add_callback(gpio, &block)
    end

    private
      @@callbacks = []

      def self.add_edge_detect(gpio, edge, bounce_time = nil)
        # TODO
      end

      def self.event_cleanup(gpio)
        # TODO
      end

      def self.event_cleanup_all
        # TODO
      end

      def self.run_callbacks(gpio)
        puts "running callbacks for GPIO #{gpio}"
        @@callbacks.each do |callback|
          if callback.gpio == gpio
            callback.call(RPi::GPIO.channel_from_gpio(gpio))
          end
        end
      end

      def self.add_callback(gpio, &block)
        puts "added callback for GPIO #{gpio}"
        callback = RPi::GPIO::Callback.new(gpio, &block)
        @@callbacks << callback
        RPi::GPIO._add_callback(gpio) # TODO replace this
      end

      class Callback
        attr_accessor :gpio, :block

        def initialize(gpio, &block)
          @gpio = gpio
          @block = block
        end
      end
  end
end
