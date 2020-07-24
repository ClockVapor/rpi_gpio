require 'rpi_gpio/rpi_gpio'
require 'epoll'

module RPi
  module GPIO
    def self.watch(channel, on:)
      RPi::GPIO.use_channel(channel, on) do |file|
        yield file.read.chomp.to_i

        epoll = Epoll.create
        epoll.add(file, Epoll::PRI)

        loop do
          file.seek(0, IO::SEEK_SET)
          epoll.wait
          yield file.read.chomp.to_i
        end
      end
    end

    def self.wait_for_edge(channel, edge)
      RPi::GPIO.use_channel(channel, edge) do |file|
        epoll = Epoll.create
        epoll.add(file, Epoll::PRI)

        loop do
          file.seek(0, IO::SEEK_SET)
          epoll.wait
        end
      end
    end

    def self.use_channel(channel, on)
      gpio = RPi::GPIO.get_gpio_number(channel)

      # Export the pin we want to watch
      File.binwrite('/sys/class/gpio/export', gpio.to_s)

      # It takes time for the pin support files to appear, so retry a few times
      retries = 0
      begin
        # `on` should be 'none', 'rising', 'falling', or 'both'
        File.binwrite("/sys/class/gpio/gpio#{gpio}/edge", on)
      rescue
        raise if retries > 3
        sleep 0.1
        retries += 1
        retry
      end

      File.open("/sys/class/gpio/gpio#{gpio}/value", 'r') do |file|
        yield file
      end
    ensure
      # Unexport the pin when we're done
      File.binwrite('/sys/class/gpio/unexport', gpio.to_s)
    end
  end
end
