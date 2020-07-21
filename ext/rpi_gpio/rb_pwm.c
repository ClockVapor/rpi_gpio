/*
Original code by Ben Croston modified for Ruby by Nick Lowery
(github.com/clockvapor)
Copyright (c) 2014-2020 Nick Lowery

Copyright (c) 2013-2018 Ben Croston

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

#include "rb_pwm.h"

extern VALUE m_GPIO;
VALUE c_PWM = Qnil;

void define_pwm_class_stuff(void)
{
  c_PWM = rb_define_class_under(m_GPIO, "PWM", rb_cObject);
  rb_define_method(c_PWM, "initialize", PWM_initialize, 2);
  rb_define_method(c_PWM, "start", PWM_start, 1);
  rb_define_method(c_PWM, "gpio", PWM_get_gpio, 0);
  rb_define_method(c_PWM, "duty_cycle", PWM_get_duty_cycle, 0);
  rb_define_method(c_PWM, "duty_cycle=", PWM_set_duty_cycle, 1);
  rb_define_method(c_PWM, "frequency", PWM_get_frequency, 0);
  rb_define_method(c_PWM, "frequency=", PWM_set_frequency, 1);
  rb_define_method(c_PWM, "stop", PWM_stop, 0);
  rb_define_method(c_PWM, "running?", PWM_get_running, 0);
}

// RPi::GPIO::PWM#initialize
VALUE PWM_initialize(VALUE self, VALUE channel, VALUE frequency)
{
  int chan;
  unsigned int gpio;
  
  chan = NUM2INT(channel);
  
  // convert channel to gpio
  if (get_gpio_number(chan, &gpio))
    return Qnil;
 
  // does soft pwm already exist on this channel?
  if (pwm_exists(gpio))
  {
    rb_raise(rb_eRuntimeError, "a PWM object already exists for this GPIO channel");
    return Qnil;
  }
  
  // ensure channel is set as output
  if (gpio_direction[gpio] != OUTPUT)
  {
    rb_raise(rb_eRuntimeError, "you must setup the GPIO channel as output "
      "first with RPi::GPIO.setup CHANNEL, :as => :output");
    return Qnil;
  }
  
  rb_iv_set(self, "@gpio", UINT2NUM(gpio));
  rb_iv_set(self, "@running", Qfalse);
  PWM_set_frequency(self, frequency);
  return self;
}

// RPi::GPIO::PWM#start
VALUE PWM_start(VALUE self, VALUE duty_cycle)
{
  pwm_start(NUM2UINT(rb_iv_get(self, "@gpio")));
  PWM_set_duty_cycle(self, duty_cycle);
  rb_iv_set(self, "@running", Qtrue);
  return self;
}

// RPi::GPIO::PWM#gpio
VALUE PWM_get_gpio(VALUE self)
{
  return rb_iv_get(self, "@gpio");
}

// RPi::GPIO::PWM#duty_cycle
VALUE PWM_get_duty_cycle(VALUE self)
{
  return rb_iv_get(self, "@duty_cycle");
}

// RPi::GPIO::PWM#duty_cycle=
VALUE PWM_set_duty_cycle(VALUE self, VALUE duty_cycle)
{
  float dc = (float) NUM2DBL(duty_cycle);
  if (dc < 0.0f || dc > 100.0f)
  {
    rb_raise(rb_eArgError, "duty cycle must be between 0.0 and 100.0");
    return Qnil;
  }
  
  rb_iv_set(self, "@duty_cycle", duty_cycle);
  pwm_set_duty_cycle(NUM2UINT(rb_iv_get(self, "@gpio")), dc);
  return self;
}

// RPi::GPIO::PWM#frequency
VALUE PWM_get_frequency(VALUE self)
{
  return rb_iv_get(self, "@frequency");
}

// RPi::GPIO::PWM#frequency=
VALUE PWM_set_frequency(VALUE self, VALUE frequency)
{
  float freq = (float) NUM2DBL(frequency);
  if (freq <= 0.0f)
  {
    rb_raise(rb_eArgError, "frequency must be greater than 0.0");
    return Qnil;
  }
  
  rb_iv_set(self, "@frequency", frequency);
  pwm_set_frequency(NUM2UINT(rb_iv_get(self, "@gpio")), freq);
  return self;
}

// RPi::GPIO::PWM#stop
VALUE PWM_stop(VALUE self)
{
  pwm_stop(NUM2UINT(rb_iv_get(self, "@gpio")));
  rb_iv_set(self, "@running", Qfalse);
  return self;
}

// RPi::GPIO::PWM#running?
VALUE PWM_get_running(VALUE self)
{
  return rb_iv_get(self, "@running");
}
