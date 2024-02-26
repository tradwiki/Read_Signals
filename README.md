# rythm-visuals-plank-5
rythm-visuals-plank-5 is an adaptation of [rythm-visuals-plank-4](https://github.com/tradwiki/rythm-visuals-plank-4). 
It transforms the reading of sensors embedded in a plank and transforms it into a midi and OSC signal to generate visuals.

## Arduino script
Planche_5_-_Read_Signals.ino is designed to be uploaded to a Teensy (3.6) controller via the arduino ide (see [Teensyduino documentation](https://www.pjrc.com/teensy/teensyduino.html)). The script sends data through the serial port to notify of an analog value spike on specified pins when the polled value is above the baseline by a certain threshold. The baseline is averaged over the previous readings while they remain below threshold. The threshold is adjusted based on signal stability to allow for more sensitive readings with more stable sensors. The script also sends and/or receives MIDI signals across USB using Teensy built-in support (see [Teensy USB MIDI documentation](https://www.pjrc.com/teensy/td_midi.html)).

The arduino script only needs to be loaded once in the Teensy of the plank.

## Python script
The python script translatez the MIDI signals coming from the plank to OSC signals. It interpretates different spikes and repetitions based on the signal received from the serial port.

The python script offers a visual interface of the incoming signals for troubleshooting through the pygame librairie.

[Sensor.py](https://github.com/tradwiki/rythm-visuals-plank-5/blob/main/python_script/Sensor.py) defines the different OSC signal parameters as well as the sensor names.
By default, data is sent to the IP address 10.10.30.44 through port 5005.

### Libraries for python
The installation of the following librairies is required for the python script
* [python-osc](https://pypi.org/project/python-osc)
* [pygame](https://www.pygame.org/wiki/GettingStarted)

### To begin
* Connect the plank to the computer that will run the python script via USB.
* Run the script [analyse_signal.py](https://github.com/tradwiki/rythm-visuals-plank-5/blob/main/python_script/analyse_signal.py)

## Processing

Rythm-visuals was developped in the specific context of video mapping through [Splash](https://sat.qc.ca/fr/splash/).
The program offers different modes of visual rendering of the plank's signal.
In order to use rythm-visuals-5 processing script, the python script must be running.

## Hardware
