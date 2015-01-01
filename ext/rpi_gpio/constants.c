/*
Original code by Ben Croston modified for Ruby by Nick Lowery
(github.com/clockvapor)
Copyright (c) 2014-2015 Nick Lowery

Copyright (c) 2013-2014 Ben Croston

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

#include "ruby.h"
#include "constants.h"
#include "common.h"
#include "c_gpio.h"
#include "event_gpio.h"

void define_constants(VALUE module)
{   
   pwm = INT2NUM(PWM);
   rb_define_const(module, "HARD_PWM", pwm);
   
   serial = INT2NUM(SERIAL);
   rb_define_const(module, "SERIAL", serial);
   
   i2c = INT2NUM(I2C);
   rb_define_const(module, "I2C", i2c);
   
   spi = INT2NUM(SPI);
   rb_define_const(module, "SPI", spi);

   unknown = INT2NUM(MODE_UNKNOWN);
   rb_define_const(module, "UNKNOWN", unknown);

   rising_edge = INT2NUM(RISING_EDGE + PY_EVENT_CONST_OFFSET);
   rb_define_const(module, "RISING", rising_edge);

   falling_edge = INT2NUM(FALLING_EDGE + PY_EVENT_CONST_OFFSET);
   rb_define_const(module, "FALLING", falling_edge);

   both_edge = INT2NUM(BOTH_EDGE + PY_EVENT_CONST_OFFSET);
   rb_define_const(module, "BOTH", both_edge);

   version = rb_str_new2("0.5.8");
   rb_define_const(module, "VERSION", version);
}
