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
use JSON;
use Getopt::Std;
use Data::Dumper;
use File::Slurp;
use Device::BCM2835;
use Time::localtime;
use strict;
use warnings;

my $DEBUG = 0;
my $globalConfigJson;

##############################
sub dieWeather($) {
    my $err = shift;
    Device::BCM2835::init() || die "could not init library";
    my $myPin = $globalConfigJson->{yellowLedPin};
    Device::BCM2835::gpio_fsel($myPin, &Device::BCM2835::BCM2835_GPIO_FSEL_OUTP);
    Device::BCM2835::gpio_write($myPin, 1);
    print $err . "\n";
    exit;
}

##############################
sub testLEDs() {
    my $count;
    my $myPin;

    Device::BCM2835::init() || die "could not init library";

    print "Flashing GREEN\n";
    $myPin = $globalConfigJson->{greenLedPin};
    Device::BCM2835::gpio_fsel($myPin, &Device::BCM2835::BCM2835_GPIO_FSEL_OUTP);
    for ($count = 0 ; $count < 5 ; $count++) {
	Device::BCM2835::gpio_write($myPin, 1);
	Device::BCM2835::delay(500);
	Device::BCM2835::gpio_write($myPin, 0);
	Device::BCM2835::delay(500);
    }

    print "Flashing YELLOW\n";
    $myPin = $globalConfigJson->{yellowLedPin};
    Device::BCM2835::gpio_fsel($myPin, &Device::BCM2835::BCM2835_GPIO_FSEL_OUTP);
    for ($count = 0 ; $count < 5 ; $count++) {
	Device::BCM2835::gpio_write($myPin, 1);
	Device::BCM2835::delay(500);
	Device::BCM2835::gpio_write($myPin, 0);
	Device::BCM2835::delay(500);
    }

    print "Flashing RED\n";
    $myPin = $globalConfigJson->{redLedPin};
    Device::BCM2835::gpio_fsel($myPin, &Device::BCM2835::BCM2835_GPIO_FSEL_OUTP);
    for ($count = 0 ; $count < 5 ; $count++) {
	Device::BCM2835::gpio_write($myPin, 1);
	Device::BCM2835::delay(500);
	Device::BCM2835::gpio_write($myPin, 0);
	Device::BCM2835::delay(500);
    }

    print "Switching RELAY\n";
    $myPin = $globalConfigJson->{relayPin};
    Device::BCM2835::gpio_fsel($myPin, &Device::BCM2835::BCM2835_GPIO_FSEL_OUTP);
    for ($count = 0 ; $count < 5 ; $count++) {
	Device::BCM2835::gpio_write($myPin, 1);
	Device::BCM2835::delay(500);
	Device::BCM2835::gpio_write($myPin, 0);
	Device::BCM2835::delay(500);
    }
}

##############################
sub sprinklerDisable() {
    my $myPin;
    print "\tsprinklerDisable(): turn sprinkler OFF\n";
    Device::BCM2835::init() || die "could not init library";
    $myPin = $globalConfigJson->{redLedPin};
    Device::BCM2835::gpio_fsel($myPin, &Device::BCM2835::BCM2835_GPIO_FSEL_OUTP);
    Device::BCM2835::gpio_write($myPin, 1);
    $myPin = $globalConfigJson->{yellowLedPin};
    Device::BCM2835::gpio_fsel($myPin, &Device::BCM2835::BCM2835_GPIO_FSEL_OUTP);
    Device::BCM2835::gpio_write($myPin, 0);
    $myPin = $globalConfigJson->{greenLedPin};
    Device::BCM2835::gpio_fsel($myPin, &Device::BCM2835::BCM2835_GPIO_FSEL_OUTP);
    Device::BCM2835::gpio_write($myPin, 0);
    $myPin = $globalConfigJson->{relayPin};
    Device::BCM2835::gpio_fsel($myPin, &Device::BCM2835::BCM2835_GPIO_FSEL_OUTP);
    Device::BCM2835::gpio_write($myPin, 1);
}

##############################
sub sprinklerEnable() {
    my $myPin;
    print "\tsprinklerEnable: turn sprinkler ON\n";
    Device::BCM2835::init() || die "could not init library";
    $myPin = $globalConfigJson->{redLedPin};
    Device::BCM2835::gpio_fsel($myPin, &Device::BCM2835::BCM2835_GPIO_FSEL_OUTP);
    Device::BCM2835::gpio_write($myPin, 0);
    $myPin = $globalConfigJson->{yellowLedPin};
    Device::BCM2835::gpio_fsel($myPin, &Device::BCM2835::BCM2835_GPIO_FSEL_OUTP);
    Device::BCM2835::gpio_write($myPin, 0);
    $myPin = $globalConfigJson->{greenLedPin};
    Device::BCM2835::gpio_fsel($myPin, &Device::BCM2835::BCM2835_GPIO_FSEL_OUTP);
    Device::BCM2835::gpio_write($myPin, 1);
    $myPin = $globalConfigJson->{relayPin};
    Device::BCM2835::gpio_fsel($myPin, &Device::BCM2835::BCM2835_GPIO_FSEL_OUTP);
    Device::BCM2835::gpio_write($myPin, 0);
}

##############################
sub verifyStatus() {
    if ($globalConfigJson->{sprinklerDisabled}) {
	sprinklerDisable();
    } else {
	sprinklerEnable();
    }
}


##############################
sub parseWeather($) {
    my $configFile = shift;
    my $disableSprinkler = 0;
    my $enableSprinkler = 0;

    ## ensure relay in proper state up front
    verifyStatus();

    ## wunderground 10 day forecast
    my $weatherURL = "http://api.wunderground.com/api/" . $globalConfigJson->{wundergroundKey} . "/forecast10day/q/" . $globalConfigJson->{zipCode} . ".json";
    print "\tFetching: $weatherURL\n";

#    my $json = read_file($inFile) || dieWeather "Can't open $inFile for reading";
    my $json = get( $weatherURL ) || dieWeather "Could not get $weatherURL";

    # Decode the wunderground json object
    my $decodedJson = decode_json( $json );
    if ($DEBUG) { print Dumper $decodedJson; }

    my ($count, $days, $icon, $chance, $month, $day, $year, $epoch, $qpf_allday, $low);
    for ( $count = 0 ; $count < $globalConfigJson->{daysDisabled} ; $count++ ) {
	$days = @{$decodedJson->{'forecast'}->{'simpleforecast'}->{'forecastday'}}[$count];

	$icon = $days->{icon};
	$chance = $days->{pop};
	$month = $days->{date}->{month};
	$day = $days->{date}->{day};
	$year = $days->{date}->{year};
	$epoch = $days->{date}->{epoch};
	$qpf_allday = $days->{qpf_allday}->{in};
	$low = $days->{low}->{fahrenheit};

	# May 2014: qpf_allday seems to be returning 'null' instead of the daily value
	# calculate out if that is the case
	if (!$qpf_allday) {
	    my ($qpf_day, $qpf_night);
	    $qpf_day   = ($days->{qpf_day}->{in}) ? $days->{qpf_day}->{in} : 0;
	    $qpf_night = ($days->{qpf_night}->{in}) ? $days->{qpf_night}->{in} : 0;
	    $qpf_allday = $qpf_day + $qpf_night;
	}
	    
	if ($DEBUG) {
	    print "$count\t$year$month$day\t$epoch\t$icon\t$chance\t$qpf_allday\t$low\n";
	}
	    
	# check rain today
	if ( $count == 0 ) {
	    if ($qpf_allday > $globalConfigJson->{rainInchThreshold}) {
		# rained above threshold - disable
		print "\tDISABLE: RAIN Today\t$year$month$day\t$epoch\t$qpf_allday\n";
		$globalConfigJson->{lastRainEpoch} = $epoch;
		$globalConfigJson->{sprinklerDisabled} = 1;
		$disableSprinkler = 1;
	    } else {
	        print "\t$year/$month/$day: no rain\n";
	    }
	} else {
	    # not today but inside our check window for the future
	    if ($chance >= $globalConfigJson->{minPctChance} ) {
		print "\tDISABLE Future: May Rain @ $epoch\t$chance\n";
		$globalConfigJson->{sprinklerDisabled} = 1;
		$disableSprinkler = 1;
	    } else {
		print "\tDay +$count: chance of rain: $chance pct\n";
	    }
	}
    }

    # we have checked today and forward, if no rain in forecase: check current status
    #  2nd if due to logic about chance of rain - requires double and
    if ($disableSprinkler == 0) {
	my $currentTempF = $decodedJson->{'forecast'}->{'simpleforecast'}->{'forecastday'}[0]->{low}->{fahrenheit};
	if ($currentTempF < $globalConfigJson->{minTempF}) {
	    print "\tTEMP TOO LOW: disable\n";
	    $globalConfigJson->{sprinklerDisabled} = 1;
	    $disableSprinkler = 1;
	} elsif ($globalConfigJson->{sprinklerDisabled}) {
	    my $currentEpoch = $decodedJson->{'forecast'}->{'simpleforecast'}->{'forecastday'}[0]->{date}->{epoch};
	    my $epochVariance = $globalConfigJson->{daysDisabled} * 60 * 60 * 24;
	    my $lastRain = $globalConfigJson->{lastRainEpoch};
	    my $newEpoch = $currentEpoch - $epochVariance;
	    
	    if ($DEBUG){
		print "\t\t\tcurrentEpoch:\t" . ctime($currentEpoch) . "\n";
		print "\t\t\tepochVariance:\t$epochVariance\n";
		print "\t\t\tlastRain:\t" . ctime($lastRain) . "\n";
		print "\t\t\tnewEpoch:\t" . ctime($newEpoch) . "\n";
	    }
	    
	    if ($globalConfigJson->{lastRainEpoch} < $newEpoch ) {
		# hasn't rained in window we care about && disabled
		print "\tRE-ENABLE Sprinkler\t$epoch\n";
		$globalConfigJson->{sprinklerDisabled} = 0;
		$enableSprinkler = 1;
	    } else {
		print "\tWill renenable at " . ctime($currentEpoch) . "\n";
	    }
	}
    }

    if ($disableSprinkler) {
	sprinklerDisable();
	my $jsonForOutput = to_json ($globalConfigJson);
	write_file ($configFile, {binmode=>':raw'}, $jsonForOutput) ||
	    dieWeather "can't write $configFile for writing";
    }
    if ($enableSprinkler) {
	sprinklerEnable();
	my $jsonForOutput = to_json ($globalConfigJson);
	write_file ($configFile, {binmode=>':raw'}, $jsonForOutput) ||
	    dieWeather "can't write $configFile for writing";
    }
}


##############################
sub initConfig($$$) {
    my $configFile = shift;
    my $wundergroundKey = shift;
    my $zipCode = shift;

    # PIN numbers to use are the GPIO pin numbers not the wiringPi or Phys ones
    #  to see use 'gpio readall'
    my %json_string = ( wundergroundKey => $wundergroundKey ,
			zipCode => $zipCode ,
			sprinklerDisabled => 0 ,
			daysDisabled => 2 ,
			relayPin => 22 ,
			redLedPin => 27 ,
			greenLedPin => 17 , 
			yellowLedPin => 10 ,
			minTempF => 40 ,
			minPctChance => 50 ,
			rainInchThreshold => 0.25 ,
			lastRainEpoch => 0
	);

    my $jsonForOutput = to_json( \%json_string );
    write_file ($configFile, {binmode=>':raw'}, $jsonForOutput) ||
	dieWeather "can't write $configFile for writing";
    print "Wrote $configFile -- exiting\n";
    exit;
}


##############################
sub usage() {
    print "$0 [options]\n";
    print "\t-r run\n";
    print "\t-c configuration file (required2run)\n";
    print "\t-i initialize config file\n";
    print "\t\t-K Weather Unground Key\n";
    print "\t\t-Z ZipCode\n";
    print "\t-usage\n";
    print "\t-T test LEDs and Relay\n";
    exit -1;
}

$Getopt::Std::opt_c = "rainBypass.config";
$Getopt::Std::opt_h = "";
$Getopt::Std::opt_i = "";
$Getopt::Std::opt_T = "";
$Getopt::Std::opt_r = "";
$Getopt::Std::opt_K = "";
$Getopt::Std::opt_Z = "06840";
Getopt::Std::getopts("rc:hiTK:Z:");
my $configFile = $Getopt::Std::opt_c;
my $init = $Getopt::Std::opt_i;
my $usage  = $Getopt::Std::opt_h;
my $test  = $Getopt::Std::opt_T;
my $run  = $Getopt::Std::opt_r;
my $wundergroundKey  = $Getopt::Std::opt_K;
my $zipCode  = $Getopt::Std::opt_Z;

system 'date';

if ($init) { initConfig($configFile, $wundergroundKey, $zipCode); exit 0; }

## read config json object
if (-e $configFile) {
    my $config = read_file($configFile) ||
	dieWeather "Can't open config file: $configFile";
    $globalConfigJson = decode_json ($config);
    if ($DEBUG) { print Dumper $globalConfigJson; }
} else {
    print "CONFIG file does not exist --- \n";
    usage();
}

if ($test) {testLEDs(); exit 0; }

## main handling
if ($run) { parseWeather($configFile); exit 0; }
usage();









