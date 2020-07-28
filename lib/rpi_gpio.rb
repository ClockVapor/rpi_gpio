require 'rpi_gpio/rpi_gpio'
require 'epoll'

module RPi
  module GPIO
    def self.watch(channel, on:, bounce_time: nil, &block) 
      gpio = get_gpio_number(channel)
      ensure_gpio_input(gpio)
      validate_edge(on)
      if bounce_time <= 0
        raise ArgumentError, "`bounce_time` must be greater than 0; given #{bounce_time}"
      end
      add_edge_detect(gpio, on, bounce_time)
      add_callback(gpio, &block)
    end

    private
      @@callbacks = []
      @@gpios = []
  
      def self.export(gpio)
        unless File.exist?("/sys/class/gpio/gpio#{gpio}")
          File.open("/sys/class/gpio/export", 'w') do |file|
            file.write(gpio.to_s)
          end
        end
      end

      def self.unexport(gpio)
        File.open("/sys/class/gpio/unexport", 'w') do |file|
          file.write(gpio.to_s)
        end
      end

      def self.set_direction(gpio, direction)
        # TODO: May need to retry opening this file several times. See original code.
        validate_direction(direction)
        File.open("/sys/class/gpio/gpio#{gpio}/direction", 'w') do |file|
          file.write(direction.to_s)
        end
      end

      def self.set_edge(gpio, edge)
        validate_edge(edge)
        File.open("/sys/class/gpio/gpio#{gpio}/edge", 'w') do |file|
          file.write(edge.to_s)
        end
      end

      def self.open_value_file(gpio)
        File.open("/sys/class/gpio/gpio#{gpio}/value", 'r')
      end

      def self.new_gpio(gpio)
        g = GPIO.new
        g.gpio = gpio
        export(gpio)
        g.exported = true
        set_direction(gpio, :in)
        begin
          g.value_file = open_value_file(gpio)
        rescue
          unexport(gpio)
          raise
        end
        g.initial_thread = true
        g.initial_wait = true
        g.bounce_time = nil
        g.last_call = 0
        g.thread_added = false
        @@gpios << g
      end

      def self.delete_gpio(gpio)
        @@gpios.delete_if { |g| g.gpio == gpio }
      end

      def self.get_event_edge(gpio)
        g = @@gpios.find { |g| g.gpio == gpio }
        if g
          return g.edge
        end
      end

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
        @@callbacks.each do |callback|
          if callback.gpio == gpio
            callback.call(RPi::GPIO.channel_from_gpio(gpio))
          end
        end
      end

      def self.add_callback(gpio, &block)
        @@callbacks << RPi::GPIO::Callback.new(gpio, &block)
        RPi::GPIO._add_callback(gpio) # TODO replace this
      end

      def validate_direction(direction)
        direction = direction.to_s
        if direction != 'in' && direction != 'out'
          raise ArgumentError, "`direction` must be 'in' or 'out'; given '#{direction}'"
        end
      end

      def validate_edge(edge)
        edge = edge.to_s
        if edge != 'rising' && edge != 'falling' && edge != 'both'
          raise ArgumentError, "`edge` must be 'rising', 'falling', or 'both'; given '#{edge}'"
        end
      end

      class GPIO
        attr_accessor :gpio, :exported, :value_file, :initial_thread, :initial_wait, :bounce_time, :last_call,
          :thread_added
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
