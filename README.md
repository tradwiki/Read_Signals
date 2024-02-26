# rythm-visuals-plank-5
rythm-visuals-plank-5 is an adaptation of [rythm-visuals-plank-4](https://github.com/tradwiki/rythm-visuals-plank-4). 
It transforms the reading of sensors embedded in a plank and transforms it into a midi and OSC signal to generate visuals.


# Arduino script
Planche_5_-_Read_Signals.ino is designed to be uploaded to a Teensy (3.6) controller via the arduino ide (see Teensyduino documentation). The script sends data through the serial port to notify of an analog value spike on specified pins when the polled value is above the baseline by a certain threshold. The baseline is averaged over the previous readings while they remain below threshold. The threshold is adjusted based on signal stability to allow for more sensitive readings with more stable sensors. The script also sends and/or receives MIDI signals across USB using Teensy built-in support (see Teensy USB MIDI documentation). It also is setup to trigger digital switches that operate solenoid motors that are used to make a puppet dance (see circuit diagram for the motors)! To know which MIDI notes are produced by the planck, you can see Read Resistance config parameter NOTES.

# Python script
The python script is a custom made program designed to translate the MIDI signals coming from the plank to OSC signals. 

## To begin
* Run the script [analyse_signal.py](https://github.com/tradwiki/rythm-visuals-plank-5/blob/main/python_script/analyse_signal.py)

## Libraries for python
The installation of the following librairies is required for the python script
* [python-osc](https://pypi.org/project/python-osc)
* [pygame](https://www.pygame.org/wiki/GettingStarted)
