RainBypass
==========

Schematics of the board:

--

Create a developer key @ weather underground to obtain the weather data.

To see if it works run the following command and verify the returned JSON
looks 'right' (insert your key and zipcode into the following):
wget -t 5 -T 60 --output-document=/home/pi/data/`date +%Y%m%d.%H%M`.json \
http://api.wunderground.com/api/WUNDERGROUND_KEY/forecast10day/q/ZIPCODE.json

--

The first time you run the script you need to initialize the config JSON.
To do this run the following with the right data:
rainBypass.pl -i rainBypass.config -K WUNDERGROUND_KEY -Z ZIPCODE

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



