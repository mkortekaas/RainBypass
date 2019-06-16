#!/usr/bin/perl

# The MIT License (MIT)
#
# Copyright (c) 2019 Mark Kortekaas
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

use strict;
use warnings;
use Device::BCM2835;

## START of HTML HEADER

print "Content-type: text/html\n\n";
print "<html>\n";
print "<div style=\"width:100%; font-size:40px; font-weight:bold; text-align:center;\">";
print "<style>
.button {
  border: none;
  color: black;
  padding: 34px 34px;
  text-align: center;
  text-decoration: none;
  display: inline-block;
  font-size: 64px;
  margin: 4px 2px;
  cursor: pointer;
  width: 100%;
}
.button1 {background-color: #4CAF50; /* Green */;}
.button2 {background-color: #f44336; /* Red */;}
</style>\n<body>\n";

## End of HTML HEADER

my $queryString = $ENV{'QUERY_STRING'};

# GPIO pin numbers
my $relayPin = 22;
my $redPin = 27;
my $greenPin = 17;
my $yellowPin = 10;

print "<a href=\"index.pl?enable\" class=\"button button1\">Enable Sprinkler</a><br>";
print "<a href=\"index.pl?disable\" class=\"button button2\">Disable Sprinkler</a><br>";
print "<hr>";

if ($queryString =~ m/enable/) {
    &sprinklerEnable($redPin, $yellowPin, $greenPin, $relayPin);
}
if ($queryString =~ m/disable/) {
    &sprinklerDisable($redPin, $yellowPin, $greenPin, $relayPin);
}
if ($queryString =~ m/test/) { 
    &testLEDs($redPin, $yellowPin, $greenPin, $relayPin);
}

&readLEDs($redPin, $yellowPin, $greenPin, $relayPin);
print "<hr>";
print "Click to <a href=\"index.pl?test\">test</a> LEDs<br>";
print "</div>\n</body>\n</html>";

##############################
sub readLEDs($$$$) {
    my ($redPin, $yellowPin, $greenPin, $relayPin) = (@_);
    Device::BCM2835::init() || die "could not init library";
    my $red = Device::BCM2835::gpio_lev($redPin);
    my $yellow = Device::BCM2835::gpio_lev($yellowPin);
    my $green = Device::BCM2835::gpio_lev($greenPin);
    my $relay = Device::BCM2835::gpio_lev($relayPin);

    if ($red && $relay && !$green) {
	print "Current Status is: disabled<br>";
    } elsif (!$red && !$relay && $green) {
	print "Current Status is: enabled<br>";
    } else {
	print "Odd Status -- UNKNOWN<br>";
    }
    print "(R:$red-Y:$yellow-G:$green-Relay:$relay)<br>";
}    
    
##############################
sub testLEDs($$$$) {
    my ($redPin, $yellowPin, $greenPin, $relayPin) = (@_);
    my $count;

    Device::BCM2835::init() || die "could not init library";

    Device::BCM2835::gpio_fsel($greenPin, &Device::BCM2835::BCM2835_GPIO_FSEL_OUTP);
    for ($count = 0 ; $count < 5 ; $count++) {
	Device::BCM2835::gpio_write($greenPin, 1);
	Device::BCM2835::delay(500);
	Device::BCM2835::gpio_write($greenPin, 0);
	Device::BCM2835::delay(500);
    }

    Device::BCM2835::gpio_fsel($yellowPin, &Device::BCM2835::BCM2835_GPIO_FSEL_OUTP);
    for ($count = 0 ; $count < 5 ; $count++) {
	Device::BCM2835::gpio_write($yellowPin, 1);
	Device::BCM2835::delay(500);
	Device::BCM2835::gpio_write($yellowPin, 0);
	Device::BCM2835::delay(500);
    }

    Device::BCM2835::gpio_fsel($redPin, &Device::BCM2835::BCM2835_GPIO_FSEL_OUTP);
    for ($count = 0 ; $count < 5 ; $count++) {
	Device::BCM2835::gpio_write($redPin, 1);
	Device::BCM2835::delay(500);
	Device::BCM2835::gpio_write($redPin, 0);
	Device::BCM2835::delay(500);
    }

    Device::BCM2835::gpio_fsel($relayPin, &Device::BCM2835::BCM2835_GPIO_FSEL_OUTP);
    for ($count = 0 ; $count < 5 ; $count++) {
	Device::BCM2835::gpio_write($relayPin, 1);
	Device::BCM2835::delay(500);
	Device::BCM2835::gpio_write($relayPin, 0);
	Device::BCM2835::delay(500);
    }
}

##############################
sub sprinklerDisable($$$$) {
    my ($redPin, $yellowPin, $greenPin, $relayPin) = (@_);
    Device::BCM2835::init() || die "could not init library";
    Device::BCM2835::gpio_fsel($redPin, &Device::BCM2835::BCM2835_GPIO_FSEL_OUTP);
    Device::BCM2835::gpio_write($redPin, 1);
    Device::BCM2835::gpio_fsel($yellowPin, &Device::BCM2835::BCM2835_GPIO_FSEL_OUTP);
    Device::BCM2835::gpio_write($yellowPin, 0);
    Device::BCM2835::gpio_fsel($greenPin, &Device::BCM2835::BCM2835_GPIO_FSEL_OUTP);
    Device::BCM2835::gpio_write($greenPin, 0);
    Device::BCM2835::gpio_fsel($relayPin, &Device::BCM2835::BCM2835_GPIO_FSEL_OUTP);
    Device::BCM2835::gpio_write($relayPin, 1);
}

##############################
sub sprinklerEnable($$$$) {
    my ($redPin, $yellowPin, $greenPin, $relayPin) = (@_);
    Device::BCM2835::init() || die "could not init library";
    Device::BCM2835::gpio_fsel($redPin, &Device::BCM2835::BCM2835_GPIO_FSEL_OUTP);
    Device::BCM2835::gpio_write($redPin, 0);
    Device::BCM2835::gpio_fsel($yellowPin, &Device::BCM2835::BCM2835_GPIO_FSEL_OUTP);
    Device::BCM2835::gpio_write($yellowPin, 0);
    Device::BCM2835::gpio_fsel($greenPin, &Device::BCM2835::BCM2835_GPIO_FSEL_OUTP);
    Device::BCM2835::gpio_write($greenPin, 1);
    Device::BCM2835::gpio_fsel($relayPin, &Device::BCM2835::BCM2835_GPIO_FSEL_OUTP);
    Device::BCM2835::gpio_write($relayPin, 0);
}


