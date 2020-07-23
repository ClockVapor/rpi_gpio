require 'rpi_gpio/rpi_gpio'
require 'epoll'

module RPi
  module GPIO
    def self.watch pin, on:
      # Export the pin we want to watch
      File.binwrite '/sys/class/gpio/export', pin.to_s

      # It takes time for the pin support files to appear, so retry a few times
      retries = 0
      begin
        # `on` should be 'none', 'rising', 'falling', or 'both'
        File.binwrite "/sys/class/gpio/gpio#{pin}/edge", on
      rescue
        raise if retries > 3
        sleep 0.1
        retries += 1
        retry
      end

      # Read the initial pin value and yield it to the block
      File.open "/sys/class/gpio/gpio#{pin}/value", 'r' do |fd|
        yield fd.read.chomp

        epoll = Epoll.create
        epoll.add fd, Epoll::PRI

        loop do
          fd.seek 0, IO::SEEK_SET
          epoll.wait # put the program to sleep until the status changes
          yield fd.read.chomp
        end
      end
    ensure
      # Unexport the pin when we're done
      File.binwrite '/sys/class/gpio/unexport', pin.to_s
    end
  end
end
