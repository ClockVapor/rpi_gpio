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

#include "rb_gpio.h"

extern VALUE m_GPIO;
int gpio_warnings = 1;

void define_gpio_module_stuff(void)
{
  rb_define_singleton_method(m_GPIO, "setup!", GPIO_setup, -1);
  rb_define_singleton_method(m_GPIO, "clean_up!", GPIO_clean_up, -1);
  rb_define_singleton_method(m_GPIO, "set_mode", GPIO_set_mode, 1);
  rb_define_singleton_method(m_GPIO, "output", GPIO_output, 2);
  rb_define_singleton_method(m_GPIO, "input", GPIO_input, 1);
  rb_define_singleton_method(m_GPIO, "set_warnings", GPIO_set_warnings, 1);
  define_constants(m_GPIO);
}

int mmap_gpio_mem(void)
{
   int result;

   if (module_setup)
      return 0;

   result = setup();
   if (result == SETUP_DEVMEM_FAIL)
   {
      rb_raise(rb_eRuntimeError, "No access to /dev/mem.  Try running as "
        "root!");
      return 1;
   } 
   else if (result == SETUP_MALLOC_FAIL) 
   {
      rb_raise(rb_eNoMemError, "Out of memory");
      return 2;
   }
   else if (result == SETUP_MMAP_FAIL) 
   {
      rb_raise(rb_eRuntimeError, "Mmap of GPIO registers failed");
      return 3;
   }
   else // result == SETUP_OK
   {
      module_setup = 1;
      return 0;
   }
}

// RPi::GPIO.clean_up(channel=nil)
// clean up everything by default; otherwise, clean up given channel
VALUE GPIO_clean_up(int argc, VALUE *argv, VALUE self)
{
   int i;
   int found = 0;
   int channel = -666; // lol, quite a flag
   unsigned int gpio;
   
   if (argc == 1)
      channel = NUM2INT(argv[0]);
   else if (argc > 1)
   {
      rb_raise(rb_eArgError, "wrong number of arguments");
      return Qnil;
   }
   
   if (channel != -666 && get_gpio_number(channel, &gpio))
      return Qnil;

   if (module_setup && !setup_error)
   {
      if (channel == -666)
      {
         // clean up any /sys/class exports
         event_cleanup_all();

         // set everything back to input
         for (i=0; i<54; i++) {
            if (gpio_direction[i] != -1) {
               setup_gpio(i, INPUT, PUD_OFF);
               gpio_direction[i] = -1;
               found = 1;
            }
         }
      }
      else
      {
         // clean up any /sys/class exports
         event_cleanup(gpio);

         // set everything back to input
         if (gpio_direction[gpio] != -1)
         {
            setup_gpio(gpio, INPUT, PUD_OFF);
            gpio_direction[gpio] = -1;
            found = 1;
         }
      }
   }

   // check if any channels set up - if not warn about misuse of GPIO.clean_up()
   if (!found && gpio_warnings)
   {
      rb_warn("No channels have been set up yet - nothing to clean "
        "up! Try cleaning up at the end of your program instead!");
   }
   
   return Qnil;
}

// RPI::GPIO.setup(channel(s), direction, pull_up_down=PUD_OFF)
VALUE GPIO_setup(int argc, VALUE *argv, VALUE self)
{
  unsigned int gpio;
  int channel = -1;
  int direction;
  int i, chancount;
  int pud = PUD_OFF + PY_PUD_CONST_OFFSET;
  int func;
  
  // func to set up channel stored in channel variable
  int setup_one(void)
  {
    if (get_gpio_number(channel, &gpio))
      return 0;

    // warn if the channel is already in use (not from this program).
    func = gpio_function(gpio);
    if (gpio_warnings &&
      ((func != 0 && func != 1) ||
      (gpio_direction[gpio] == -1 && func == 1)))
    {
      rb_warn("This channel is already in use; continuing anyway. "
        "Use RPi::GPIO.set_warnings(False) to disable warnings.");
    }

      setup_gpio(gpio, direction, pud);
      gpio_direction[gpio] = direction;
      return 1;
  }

  // parse arguments
  if (argc < 2)
  {
    rb_raise(rb_eArgError, "not enough arguments; need (2..3)");
    return Qnil;
  }
  else if (argc == 2 || argc == 3)
  {
    if (TYPE(argv[0]) == T_ARRAY)
      chancount = RARRAY_LEN(argv[0]);
    else
    {
      channel = NUM2INT(argv[0]);
      chancount = 1;
    }

    direction = NUM2INT(argv[1]);

    if (argc == 3)
      pud = NUM2INT(argv[2]);
  }
  else
  {
    rb_raise(rb_eArgError, "too many arguments; need (2..3)");
    return Qnil;
  }

  // check module has been imported cleanly
  if (setup_error)
  {
    rb_raise(rb_eRuntimeError, "Module not imported correctly!");
    return Qnil;
  }

  if (mmap_gpio_mem())
    return Qnil;

  if (direction != INPUT && direction != OUTPUT)
  {
    rb_raise(rb_eArgError, "Invalid direction");
    return Qnil;
  }

  if (direction == OUTPUT)
    pud = PUD_OFF + PY_PUD_CONST_OFFSET;

  pud -= PY_PUD_CONST_OFFSET;
  if (pud != PUD_OFF && pud != PUD_DOWN && pud != PUD_UP) 
  {
    rb_raise(rb_eArgError, "Invalid value for pull_up_down - "
      "should be either PUD_OFF, PUD_UP or PUD_DOWN");
    return Qnil;
  }

  // given a single channel
  if (chancount == 1)
  {
    if (!setup_one())
      return Qnil;
  }

  // else given an array of channels
  else
  {
    for (i=0; i<chancount; i++)
    {
      channel = NUM2INT(rb_ary_entry(argv[0], i));
      if (!setup_one())
         return Qnil;
    }
  }

  return self;
}

// RPi::GPIO.set_mode(mode)
VALUE GPIO_set_mode(VALUE self, VALUE mode)
{
  gpio_mode = NUM2INT(mode);

  if (setup_error)
  {
    rb_raise(rb_eRuntimeError, "Module not imported correctly!");
    return Qnil;
  }

  if (gpio_mode != BOARD && gpio_mode != BCM)
  {
    rb_raise(rb_eArgError, "Invalid mode");
    return Qnil;
  }

  if (revision == 0 && gpio_mode == BOARD)
  {
    rb_raise(rb_eRuntimeError, "BOARD numbering system not applicable on "
      "computer module");
    return Qnil;
  }

  return self;
}

// RPi::GPIO.output(channel(s), val(s))
VALUE GPIO_output(VALUE self, VALUE channels, VALUE vals)
{
  unsigned int gpio;
  int channel = -1;
  int value = -1;
  int i;
  int chancount = 1;
  int valuecount = 1;

  // func to output value var on channel var
  int output(void)
  {
    if (get_gpio_number(channel, &gpio))
      return 0;

    if (gpio_direction[gpio] != OUTPUT)
    {
      rb_raise(rb_eRuntimeError, "GPIO channel not set as OUTPUT");
      return 0;
    }

    if (check_gpio_priv())
      return 0;

    output_gpio(gpio, value);
    return 1;
  }

  // parse channels and values
  if (TYPE(channels) == T_ARRAY)
    chancount = RARRAY_LEN(channels);
  else
    channel = NUM2INT(channels);
  if (TYPE(vals) == T_ARRAY)
    valuecount = RARRAY_LEN(vals);
  else
    value = NUM2INT(vals);
  if (chancount != valuecount)
  {
    rb_raise(rb_eArgError, "Need same number of channels and values");
    return Qnil;
  }

  // given one channel/value
  if (chancount == 1)
  {
    if (!output())
      return Qnil;
  }
  
  // else given multiple channels/values
  else
  {
    for (i=0; i<chancount; i++)
    {
      channel = NUM2INT(rb_ary_entry(channels, i));
      value = NUM2INT(rb_ary_entry(vals, i));
      if (!output())
        return Qnil;
    }
  }

  return self;
}

// RPi::GPIO.input(channel)
VALUE GPIO_input(VALUE self, VALUE channel)
{
  unsigned int gpio;
  
  if (get_gpio_number(NUM2INT(channel), &gpio))
    return Qnil;

  if (gpio_direction[gpio] != INPUT && gpio_direction[gpio] != OUTPUT)
  {
    rb_raise(rb_eRuntimeError, "You must setup() the GPIO channel first");
    return Qnil;
  }

  if (check_gpio_priv())
    return Qnil;
  
  if (input_gpio(gpio))
    return NUM2INT(HIGH);
  else
    return NUM2INT(LOW);
}

// RPi::GPIO.set_warnings(state)
VALUE GPIO_set_warnings(VALUE self, VALUE setting)
{
  if (setup_error)
  {
    rb_raise(rb_eRuntimeError, "Module not imported correctly!");
    return Qnil;
  }

  gpio_warnings = NUM2INT(setting);
  return self;
}
