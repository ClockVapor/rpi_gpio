require "rpi_gpio"

RPi::GPIO.set_numbering :board
RPi::GPIO.setup 11, :as => :output

3.times do
  RPi::GPIO.set_high 11
  sleep 1
  RPi::GPIO.set_low 11
  sleep 1
end

RPi::GPIO.reset