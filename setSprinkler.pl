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

use LWP::Simple;
use Getopt::Std;
use Device::BCM2835;
use Time::localtime;
use strict;
use warnings;

##############################
sub readLEDs($$$$) {
    my ($redPin, $yellowPin, $greenPin, $relayPin) = (@_);
    Device::BCM2835::init() || die "could not init library";
    my $red = Device::BCM2835::gpio_lev($redPin);
    my $yellow = Device::BCM2835::gpio_lev($yellowPin);
    my $green = Device::BCM2835::gpio_lev($greenPin);
    my $relay = Device::BCM2835::gpio_lev($relayPin);
    print "Red:\t$red\nYellow:\t$yellow\nGreen:\t$green\nRelay:\t$relay\n";
}    
    
##############################
sub testLEDs($$$$) {
    my ($redPin, $yellowPin, $greenPin, $relayPin) = (@_);
    my $count;

    Device::BCM2835::init() || die "could not init library";

    print "Flashing GREEN\n";
    Device::BCM2835::gpio_fsel($greenPin, &Device::BCM2835::BCM2835_GPIO_FSEL_OUTP);
    for ($count = 0 ; $count < 5 ; $count++) {
	Device::BCM2835::gpio_write($greenPin, 1);
	Device::BCM2835::delay(500);
	Device::BCM2835::gpio_write($greenPin, 0);
	Device::BCM2835::delay(500);
    }

    print "Flashing YELLOW\n";
    Device::BCM2835::gpio_fsel($yellowPin, &Device::BCM2835::BCM2835_GPIO_FSEL_OUTP);
    for ($count = 0 ; $count < 5 ; $count++) {
	Device::BCM2835::gpio_write($yellowPin, 1);
	Device::BCM2835::delay(500);
	Device::BCM2835::gpio_write($yellowPin, 0);
	Device::BCM2835::delay(500);
    }

    print "Flashing RED\n";
    Device::BCM2835::gpio_fsel($redPin, &Device::BCM2835::BCM2835_GPIO_FSEL_OUTP);
    for ($count = 0 ; $count < 5 ; $count++) {
	Device::BCM2835::gpio_write($redPin, 1);
	Device::BCM2835::delay(500);
	Device::BCM2835::gpio_write($redPin, 0);
	Device::BCM2835::delay(500);
    }

    print "Switching RELAY\n";
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
    print "\tsprinklerDisable(): turn sprinkler OFF\n";
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
    print "\tsprinklerEnable: turn sprinkler ON\n";
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

##############################
sub usage() {
    print "$0 [options]\n";
    print "\t-help\n";
    print "\t-status\n";
    print "\t-enable\n";
    print "\t-disable\n";
    print "\t-Test LEDs and Relay\n";
    print "\t-relayPin (22)\n";
    print "\t-RedPin (27)\n";
    print "\t-GreenPin (17)\n";
    print "\t-YellowPin (10)\n";
    exit -1;
}

$Getopt::Std::opt_h = "";
$Getopt::Std::opt_e = "";
$Getopt::Std::opt_d = "";
$Getopt::Std::opt_T = "";
$Getopt::Std::opt_r = 22;
$Getopt::Std::opt_R = 27;
$Getopt::Std::opt_G = 17;
$Getopt::Std::opt_Y = 10;
$Getopt::Std::opt_s = "";
Getopt::Std::getopts("shedTr:R:G:Y:");
my $usage  = $Getopt::Std::opt_h;
my $test  = $Getopt::Std::opt_T;
my $enable  = $Getopt::Std::opt_e;
my $disable  = $Getopt::Std::opt_d;
my $relayPin = $Getopt::Std::opt_r;
my $redPin = $Getopt::Std::opt_R;
my $greenPin = $Getopt::Std::opt_G;
my $yellowPin = $Getopt::Std::opt_Y;
my $status = $Getopt::Std::opt_s;

system 'date';

if ($status) { readLEDs($redPin, $yellowPin, $greenPin, $relayPin); exit 0; }
if ($test) { testLEDs($redPin, $yellowPin, $greenPin, $relayPin); exit 0; }
if ($enable) { sprinklerEnable($redPin, $yellowPin, $greenPin, $relayPin); exit 0; }
if ($disable) { sprinklerDisable($redPin, $yellowPin, $greenPin, $relayPin); exit 0; }
usage();









