#!/usr/bin/perl

# The MIT License (MIT)
#
# Copyright (c) 2013 Mark Kortekaas
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

use Device::BCM2835;
use strict;
use warnings;

sub flashLED($) {
    my $myPin = shift;
    my $count;

    # PIN numbers to use are the BCM pin numbers not the wiringPi or Phys ones
    #  to see use 'gpio readall'
    Device::BCM2835::init() || die "could not init library";

    print "Flashing PIN: $myPin\n";
    Device::BCM2835::gpio_fsel($myPin,&Device::BCM2835::BCM2835_GPIO_FSEL_OUTP);
    for ($count = 0 ; $count < 4 ; $count++) {
	Device::BCM2835::gpio_write($myPin, 1);
	Device::BCM2835::delay(250);
	Device::BCM2835::gpio_write($myPin, 0);
	Device::BCM2835::delay(250);
    }
}

flashLED(13);
flashLED(19);
flashLED(26);
exit;






