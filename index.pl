#!/usr/bin/perl

use strict;
use warnings;
use Device::BCM2835;

print "Content-type: text/html\n\n";
print "<html>\n<body>\n";
print "<div style=\"width:100%; font-size:40px; font-weight:bold; text-align:center;\">";
print "Click to <a href=\"index.pl?enable\">enable</a> sprinkler<br>";
print "Click to <a href=\"index.pl?disable\">disable</a> sprinkler<br>";
print "<hr>";

#foreach my $key (keys %ENV) {
#    print "$key --> $ENV{$key}<br>";
#}

my $queryString = $ENV{'QUERY_STRING'};

# GPIO pin numbers
my $relayPin = 22;
my $redPin = 27;
my $greenPin = 17;
my $yellowPin = 10;

if ($queryString =~ m/enable/) {
    sprinklerEnable($redPin, $yellowPin, $greenPin, $relayPin);
}
if ($queryString =~ m/disable/) {
    sprinklerDisable($redPin, $yellowPin, $greenPin, $relayPin);
}
if ($queryString =~ m/test/) { 
    testLEDs($redPin, $yellowPin, $greenPin, $relayPin);
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
    print "Red:\t$red<br>Yellow:\t$yellow<br>Green:\t$green<br>Relay:\t$relay<br>";
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


