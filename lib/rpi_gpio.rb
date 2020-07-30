require 'rpi_gpio/rpi_gpio'
require 'epoll'

module RPi
  module GPIO
    def self.watch(channel, on:, bounce_time: nil, &block) 
      gpio = get_gpio_number(channel)
      ensure_gpio_input(gpio)
      validate_edge(on)
      if bounce_time && bounce_time <= 0
        raise ArgumentError, "`bounce_time` must be greater than 0; given #{bounce_time}"
      end
      add_edge_detect(gpio, on, bounce_time)
      add_callback(gpio, &block)
    end

    def self.stop_watching(channel)
      gpio = get_gpio_number(channel)
      ensure_gpio_input(gpio)
      remove_edge_detect(gpio)
      remove_callbacks(gpio)
    end

    def self.wait_for_edge(channel, edge, bounce_time: nil, timeout: -1)
      gpio = get_gpio_number(channel)
      if callback_exists(gpio)
        raise RuntimeError, "conflicting edge detection already enabled for GPIO #{gpio}"
      end

      ensure_gpio_input(gpio)
      validate_edge(edge)
      was_gpio_new = false
      current_edge = get_event_edge(gpio)
      if current_edge == edge
        g = get_gpio(gpio)
        if g.bounce_time && g.bounce_time != bounce_time
          raise RuntimeError, "conflicting edge detection already enabled for GPIO #{gpio}"
        end
      elsif current_edge.nil?
        was_gpio_new = true
        g = new_gpio(gpio)
        set_edge(gpio, edge)
        g.edge = edge
        g.bounce_time = bounce_time
      else
        g = get_gpio(gpio)
        set_edge(gpio, edge)
        g.edge = edge
        g.bounce_time = bounce_time
        g.initial_wait = 1
      end

      if @@epoll_blocking.nil?
        @@epoll_blocking = Epoll.create
      end
      @@epoll_blocking.add(g.value_file, Epoll::PRI)

      initial_edge = true
      the_value = nil
      timed_out = false
      begin
        while the_value.nil? && !timed_out do
          events = @@epoll_blocking.wait(timeout)
          if events.empty?
            timed_out = true
          end
          events.each do |event|
            if event.events & Epoll::PRI != 0
              event.data.seek(0, IO::SEEK_SET)
              value = event.data.read.chomp.to_i
              if event.data == g.value_file
                if initial_edge # ignore first epoll trigger
                  initial_edge = false
                else
                  now = Time.now.to_f
                  if g.bounce_time.nil? || g.last_call == 0 || g.last_call > now ||
                     (now - g.last_call) * 1000 > g.bounce_time then
                    g.last_call = now
                    the_value = value
                  end
                end
              end
            end
          end
        end

        if the_value
          return the_value
        end
      ensure
        @@epoll_blocking.del(g.value_file)
        if was_gpio_new
          delete_gpio(gpio)
        end
      end
    end

    private
      @@callbacks = []
      @@gpios = []
      @@epoll = nil
      @@epoll_thread = nil
      @@epoll_blocking = nil
  
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
        validate_direction(direction)
        tries = 0
        begin
          File.open("/sys/class/gpio/gpio#{gpio}/direction", 'w') do |file|
            file.write(direction.to_s)
          end
        rescue
          raise if tries > 5
          sleep 0.1
          tries += 1
          retry
        end
      end

      def self.set_edge(gpio, edge)
        validate_edge(edge)
        tries = 0
        begin
          File.open("/sys/class/gpio/gpio#{gpio}/edge", 'w') do |file|
            file.write(edge.to_s)
          end
        rescue
          raise if tries > 5
          sleep 0.1
          tries += 1
          retry
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
        g
      end

      def self.delete_gpio(gpio)
        @@gpios.delete_if { |g| g.gpio == gpio }
      end

      def self.get_gpio(gpio)
        @@gpios.find { |g| g.gpio == gpio }
      end

      def self.get_gpio_by_value_file(value_file)
        @@gpios.find { |g| g.value_file == value_file }
      end

      def self.get_event_edge(gpio) # gpio_event_added in python library
        g = @@gpios.find { |g| g.gpio == gpio }
        if g
          return g.edge
        end
      end

      def self.add_edge_detect(gpio, edge, bounce_time = nil)
        current_edge = get_event_edge(gpio)
        if current_edge.nil?
          g = new_gpio(gpio)
          set_edge(gpio, edge)
          g.edge = edge
          g.bounce_time = bounce_time
        elsif current_edge == edge
          g = get_gpio(gpio)
          if (bounce_time && g.bounce_time != bounce_time) || g.thread_added
            raise RuntimeError, "conflicting edge detection already enabled for GPIO #{gpio}"
          end
        else
          raise RuntimeError, "conflicting edge detection already enabled for GPIO #{gpio}"
        end

        if @@epoll.nil?
          @@epoll = Epoll.create
        end

        begin
          @@epoll.add(g.value_file, Epoll::PRI)
        rescue
          remove_edge_detect(gpio)
          raise
        end

        g.thread_added = true
        if @@epoll_thread.nil? || !@@epoll_thread.alive?
          @@epoll_thread = Thread.new { poll_thread }
        end
      end

      def self.remove_edge_detect(gpio)
        g = get_gpio(gpio)
        if g and @@epoll
          @@epoll.del(g.value_file)
          set_edge(gpio, :none)
          g.edge = :none
          g.value_file.close
          unexport(gpio)
          delete_gpio(gpio)
        end
      end

      def self.poll_thread
        loop do
          begin
            events = @@epoll.wait
          rescue IOError # empty interest list
            break
          end
          events.each do |event|
            if event.events & Epoll::PRI != 0
              event.data.seek(0, IO::SEEK_SET)
              g = get_gpio_by_value_file(event.data)
              value = event.data.read.chomp.to_i
              if g.initial_thread # ignore first epoll trigger
                g.initial_thread = false
              else
                now = Time.now.to_f
                if g.bounce_time.nil? || g.last_call == 0 || g.last_call > now ||
                   (now - g.last_call) * 1000 > g.bounce_time then
                  g.last_call = now
                  run_callbacks(g.gpio, value)
                end
              end
            end
          end
        end
      end

      def self.event_cleanup(gpio)
        @@gpios.map { |g| g.gpio }.each do |gpio_|
          if gpio.nil? || gpio_ == gpio
            remove_edge_detect(gpio_)
          end
        end

        if @@gpios.empty? && @@epoll_thread
          @@epoll_thread.terminate
        end
      end

      def self.event_cleanup_all
        event_cleanup(nil)
      end

      def self.add_callback(gpio, &block)
        @@callbacks << Callback.new(gpio, &block)
      end

      def self.remove_callbacks(gpio)
        @@callbacks.delete_if { |g| g.gpio == gpio }
      end

      def self.callback_exists(gpio)
        @@gpios.find { |g| g.gpio == gpio } != nil
      end

      def self.run_callbacks(gpio, value)
        @@callbacks.each do |callback|
          if callback.gpio == gpio
            callback.block.call(channel_from_gpio(gpio), value)
          end
        end
      end

      def self.validate_direction(direction)
        direction = direction.to_s
        if direction != 'in' && direction != 'out'
          raise ArgumentError, "`direction` must be 'in' or 'out'; given '#{direction}'"
        end
      end

      def self.validate_edge(edge)
        edge = edge.to_s
        if edge != 'rising' && edge != 'falling' && edge != 'both' && edge != 'none'
          raise ArgumentError, "`edge` must be 'rising', 'falling', 'both', or 'none'; given '#{edge}'"
        end
      end

      class GPIO
        attr_accessor :gpio, :exported, :value_file, :initial_thread, :initial_wait, :bounce_time, :last_call,
          :thread_added, :edge
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
