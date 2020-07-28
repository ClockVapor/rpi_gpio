/*
Original code by Ben Croston modified for Ruby by Nick Lowery
(github.com/clockvapor)
Copyright (c) 2014-2020 Nick Lowery

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
#include "c_gpio.h"
#include "cpuinfo.h"
#include "common.h"
#include "rb_pwm.h"

void define_gpio_module_stuff(void);
int mmap_gpio_mem(void);
int is_gpio_initialized(unsigned int gpio);
int is_gpio_output(unsigned int gpio);
int is_rpi(void);
VALUE GPIO_clean_up(int argc, VALUE *argv, VALUE self);
VALUE GPIO_reset(VALUE self);
VALUE GPIO_setup(VALUE self, VALUE channel, VALUE hash);
VALUE GPIO_set_numbering(VALUE self, VALUE mode);
VALUE GPIO_set_high(VALUE self, VALUE channel);
VALUE GPIO_set_low(VALUE self, VALUE channel);
VALUE GPIO_test_high(VALUE self, VALUE channel);
VALUE GPIO_test_low(VALUE self, VALUE channel);
VALUE GPIO_set_warnings(VALUE self, VALUE setting);
VALUE GPIO_get_gpio_number(VALUE self, VALUE channel);
VALUE GPIO_channel_from_gpio(VALUE self, VALUE gpio);
VALUE GPIO_ensure_gpio_input(VALUE self, VALUE gpio);
