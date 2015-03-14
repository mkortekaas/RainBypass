RainBypass
==========

I got the start of all of this from http://www.thirdeyevis.com/pi-page-3.php
- I wanted to run this not as a deamon but as a cron task 
- The original worked but as I do not spend too much time with python, it was easier
  for me to rewrite this in perl

For parts you need:
- Pi Model B (the 2 may work, haven't tested) (adafruit: 
- adafruit prototyping Pi Plate Kit (adafruit: 801)
- tiny breadboard (adafruit ID:65)
- assorted 5mm LEDs (i got from Amazon)
- 40P dupont cable 200nm male to female (I pulled indivdual cables off for my need)
- 1x SainSmart 2-Channel Relay Module (http://www.amazon.com/gp/product/B0057OC6D8/ref=oh_aui_detailpage_o01_s00?ie=UTF8&psc=1) 
- 1x 1k resistor
- 3x 51 ohm resistors
- 1x zener diode
- 1x 2n2222 transistor

Easier to see the diagram at the site above, but I started with the PI and added
the prototyping board with the tiny breadboard. I guess I could have soldered this 
together to be more stable, but it's mounted in a box in my garage and using the
breadboard made it easier to put together/debug. Plus my soldering skills were already
tested building the prototyping kit 

the diagram looks like:
RPi Pin 1 (+3.3V): to relay and diode, then to transistor leg1
GPIO Pin 22 (+3.3V): to 1k resistor then to transistor center
GPIO Pin 27 (+3.3V): to red led, then to 51 ohm, then to ground
GPIO Pin 17 (+3.3V): to green led, then to 51 ohm, then to ground
GPIO Pin 10 (+3.3V): to yellow led, then to 51 ohm, then to ground
RPi Pin 6 (ground): to led(s) above and to 3rd leg on transitor


--

Create a developer key @ weather underground to obtain the weather data.

To see if it works run the following command and verify the returned JSON
looks 'right' (insert your key and zipcode into the following):
wget -t 5 -T 60 --output-document=/home/pi/data/`date +%Y%m%d.%H%M`.json \
http://api.wunderground.com/api/WUNDERGROUND_KEY/forecast10day/q/ZIPCODE.json

--

The first time you run the script you need to initialize the config JSON.
To do this run the following with the right data:
rainBypass.pl -i -c rainBypass.config -K WUNDERGROUND_KEY -Z ZIPCODE

The script assumes these are the hardware locations you've built with:
                        relayPin => 22 ,
                        redLedPin => 27 ,
                        greenLedPin => 17 ,
                        yellowLedPin => 10 

And it assumes you are good with these defaults that I use:
                        daysDisabled => 2 ,
                        minTempF => 40 ,
                        minPctChance => 50 ,
                        rainInchThreshold => 0.25 

If you would prefer different settings you'll need to edit the created JSON
or rainBypass.pl itself to change them off the defaults.

-- 

To test that the wiring is correct run the script as follows:
rainBypass.pl -c rainBypass.config -T

You should see the LEDs cycle as well as hear the relay flip. You may need to
run this as root depending on how your PI was built.

--

To run the script itself once you've done the above:
rainBypass.pl -r -c rainBypass.config

I have this set to run hourly and my crontab (roots) looks like:
31 * * * * /home/pi/git/RainBypass/rainBypass.pl -r -c /home/pi/git/RainBypass/rainBypass.config >> /var/log/rainBypass.log 2>&1


--



