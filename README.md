# rythm-visuals-plank-5
rythm-visuals-plank-5 is an adaptation of [rythm-visuals-plank-4](https://github.com/tradwiki/rythm-visuals-plank-4). 
It transforms the reading of sensors embedded in a plank and transforms it into a midi and OSC signal to generate visuals.
This project showcases the use of analog piezo sensors and FSR sensors sending MIDI signals through a custom circuit that are translated in OSC through python and sent to a processing program to generate visuals.

## Planche_5_-_Read_Signals (Arduino Script)
[Planche_5_-_Read_Signals](https://github.com/tradwiki/rythm-visuals-plank-5/tree/main/Planche_5_-_Read_Signals) is designed to be uploaded to a Teensy (3.6) controller via the arduino IDE (see [Teensyduino documentation](https://www.pjrc.com/teensy/teensyduino.html)). The script sends data through the serial port to notify of an analog value spike on specified pins when the polled value is above the baseline by a certain threshold. The baseline is averaged over the previous readings while they remain below threshold. The threshold is adjusted based on signal stability to allow for more sensitive readings with more stable sensors. The script also sends and/or receives MIDI signals across USB using Teensy built-in support (see [Teensy USB MIDI documentation](https://www.pjrc.com/teensy/td_midi.html)).
<span style="color: red;">The arduino script only needs to be loaded once in the Teensy of the plank.</span> 
### Configuration
Modify [config.h](https://github.com/tradwiki/rythm-visuals-plank-5/blob/main/Planche_5_-_Read_Signals/config.h) to modify thresholds, delays, notes, pins, debug.
#### Considerations
* Midi pin values are specific to the circuit design
* Analyse_Signal configurations are dependant of current MIDI note configurations
* Drawplank 2.0 configurations are dependant of the current configurations
* Thresholds, baselines and delays are the result of physical tests on the plank and may vary for specific constructions

## Analyse Signal (Python script)
The python script translates MIDI signals coming from the plank to OSC signals. It interpretates different spikes and repetitions based on the signal received from the serial port as well as bpm.
The python script offers a visual interface of the incoming signals for troubleshooting through the pygame librairie.
### Configuration
[Sensor.py](https://github.com/tradwiki/rythm-visuals-plank-5/blob/main/python_script/Sensor.py) defines the different OSC signal parameters as well as the sensor names.
By default, data is sent to the IP address 10.10.30.44 through port 5005.
#### Libraries for python
The installation of the following librairies is required for the python script to run.
* [python-osc](https://pypi.org/project/python-osc)
* [pygame](https://www.pygame.org/wiki/GettingStarted)

## Processing
[Drawplank 2.0] was developped in the specific context of video mapping through [Splash](https://sat.qc.ca/fr/splash/).
The program offers different modes of visual rendering of the plank's signal. 
<span style="color: red;">In order to use Drawplank 2.0, the python script must be running.</span> 
### Modes
Drawplank 2.0 offers 4 different modes
* Monitor
* Mondrian
* Raindrop
* Reboisons
### Use
To select mode, the corresponding pad must be held.
To exit a selected mode, the upper left pad must be held down.

## Device
A custom pcb was printed for this project. The circuit uses 8 FSR sensors and 5 Piezo sensors.
One piezo sensor is used as a surface microphone and does not produce a digital signal.
The plank was cut using a CNC.
Further discription is available in the circuit folder.

### List of parts
* [FSR Sensor](https://www.sparkfun.com/products/9376) * 8
* [Piezo Sensor](https://www.digikey.ca/en/products/detail/7BB-35-3C/490-7716-ND/4358156?utm_medium=email&utm_source=oce&utm_campaign=4251_OCE21RT&utm_content=productdetail_CA&utm_cid=2404724&so=73383872)
* [LM358P Amplifier](https://www.digikey.ca/en/products/detail/LM358P/296-1395-5-ND/277042?utm_medium=email&utm_source=oce&utm_campaign=4251_OCE21RT&utm_content=productdetail_CA&utm_cid=2404724&so=73383872) * 4
* [SBL5100 Schottky diode](https://www.digikey.ca/en/products/detail/SBL5100TA/1655-1527-1-ND/6022972?utm_medium=email&utm_source=oce&utm_campaign=4251_OCE21RT&utm_content=productdetail_CA&utm_cid=2404724&so=73383872) * 8
* [5 kOhm Resistor](


### Getting started
* Connect the plank to the computer via USB.
* Run the script [analyse_signal.py](https://github.com/tradwiki/rythm-visuals-plank-5/blob/main/python_script/analyse_signal.py)
* Run Drawplank 2.0 script.

