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

#include <stdio.h>
#include <string.h>
#include "cpuinfo.h"

char *get_cpuinfo_revision(char *revision)
{
   FILE *fp;
   char buffer[1024];
   char hardware[1024];
   int  rpi_found = 0;

   if ((fp = fopen("/proc/cpuinfo", "r")) == NULL)
      return 0;

   while(!feof(fp)) {
      fgets(buffer, sizeof(buffer) , fp);
      sscanf(buffer, "Hardware	: %s", hardware);
      if (strcmp(hardware, "BCM2708") == 0)
         rpi_found = 1;
      sscanf(buffer, "Revision	: %s", revision);
   }
   fclose(fp);

   if (!rpi_found)
      revision = NULL;
   return revision;
}

int get_rpi_revision(void)
{
   char raw_revision[1024] = {'\0'};
   int len;
   char *revision;

   if (get_cpuinfo_revision(raw_revision) == NULL)
      return -1;

   // get last four characters (ignore preceeding 1000 for overvolt)
   len = strlen(raw_revision);
   if (len > 4)
      revision = (char *)&raw_revision+len-4;
   else
      revision = raw_revision;

   if ((strcmp(revision, "0002") == 0) ||
       (strcmp(revision, "0003") == 0))
      return 1;
   else if ((strcmp(revision, "0004") == 0) ||
            (strcmp(revision, "0005") == 0) ||
            (strcmp(revision, "0006") == 0) ||
            (strcmp(revision, "0007") == 0) ||
            (strcmp(revision, "0008") == 0) ||
            (strcmp(revision, "0009") == 0) ||
            (strcmp(revision, "000d") == 0) ||
            (strcmp(revision, "000e") == 0) ||
            (strcmp(revision, "000f") == 0))
      return 2;  // revision 2
   else if (strcmp(revision, "0011") == 0)
      return 0;  // compute module
   else   // assume B+ (0010) or A+ (0012)
      return 3;
}
