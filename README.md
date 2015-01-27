#rpi_gpio v0.1.5

Ruby conversion of [RPi.GPIO Python module](https://pypi.python.org/pypi/RPi.GPIO)

##Features

Manipulate your Raspberry Pi's GPIO pins from Ruby!
- Boolean input/output
- Software-driven PWM (written in C for speed)
- *Upcoming*: event-driven input

##Sample Usage

I aimed to make the gem's usage exactly the same as its Python counterpart -- only with a few semantic differences to utilize Ruby's readability. If anything is confusing, you can always check [here](http://sourceforge.net/p/raspberry-gpio-python/wiki/Examples/) for the original Python module's documentation.

####Download the gem

The easiest way to download the gem is to use [Bundler](http://bundler.io/) with a Gemfile. In your Gemfile, include the line 
```ruby
gem 'rpi_gpio'
```
Then you can run `bundle install` to automatically download and compile the gem for your system. To include the gem in a Ruby file, use the line `require 'rpi_gpio'`.

####Pin numbering

Before you can do anything with the GPIO pins, you need to specify how you want to number them.
```ruby
RPi::GPIO.set_numbering :board
# or
RPi::GPIO.set_numbering :bcm
````
`:board` numbering refers to the physical pin numbers on the Pi, whereas `:bcm` numbering refers to the Broadcom SOC channel numbering. Note that `:bcm` numbering differs between Pi models, while `:board` numbering does not.

####Input

To receive input from a GPIO pin, you must first initialize it as an input pin:
```ruby
RPi::GPIO.setup PIN_NUM, :as => :input
```
The pin number will differ based on your selected numbering system and which pin you want to use.

Now you can use the calls
```ruby
RPi::GPIO.high? PIN_NUM
RPi::GPIO.low? PIN_NUM
```
to receive either `true` or `false`.

You can use the additional hash argument `:pull` to apply a pull-up or pull-down resistor to the input pin like so:
```ruby
RPi::GPIO.setup PIN_NUM, :as => :input, :pull => :down
# or
RPi::GPIO.setup PIN_NUM, :as => :input, :pull => :up
# or (not necessary; :off is the default value)
RPi::GPIO.setup PIN_NUM, :as => :input, :pull => :off
```

####Output

To send output to a GPIO pin, you must first initialize it as an output pin:
```ruby
RPi::GPIO.setup PIN_NUM, :as => :output
```
Now you can use the calls
```ruby
RPi::GPIO.set_high PIN_NUM
RPi::GPIO.set_low PIN_NUM
```
to set the pin either high or low.

####PWM (pulse-width modulation)

Pulse-width modulation is a useful tool for controlling things like LED brightness or motor speed. To utilize PWM, first create a PWM object for an output pin.
```ruby
pwm = RPi::GPIO::PWM.new(PIN_NUM, PWM_FREQ)
```
The `PWM_FREQ` is a value in hertz that specifies the amount of pulse cycles per second.

Now you can call the following method to start PWM:
```ruby
pwm.start DUTY_CYCLE
```
`DUTY_CYCLE` is a value from `0.0` to `100.0` indicating the percent of the time that the signal will be high.

Once running, you can get/set the PWM duty cycle with
```ruby
pwm.duty_cycle # get
pwm.duty_cycle = NEW_DUTY_CYCLE # set
```
get/set the PWM frequency with
```ruby
pwm.frequency # get
pwm.frequency = NEW_FREQUENCY # set
```
and get the PWM GPIO pin with
```ruby
pwm.pin
```

To stop PWM, use
```ruby
pwm.stop
```

####Cleaning up

After your program is finished using the GPIO pins, it's a good idea to release them so other programs can use them later. Simply call
```ruby
RPi::GPIO.clean_up PIN_NUM
```
to release a specific pin, or
```ruby
RPi::GPIO.clean_up
```
to release all allocated pins.

##Credits

Original Python code by Ben Croston modified for Ruby by Nick Lowery

Copyright (c) 2014-2015 [Nick Lowery](https://github.com/ClockVapor)

View LICENSE for full license.

All donations are gratefully accepted. 

<a href="https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=nick%2ea%2elowery%40gmail%2ecom&lc=US&item_name=Nick%20Lowery%3a%20open%2dsource%20software&no_note=0&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donate_LG%2egif%3aNonHostedGuest"><img alt="Donate here" src="https://www.paypalobjects.com/en_US/i/btn/btn_donate_LG.gif"></a>
