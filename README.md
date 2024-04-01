# rythm-visuals-plank-5
![Podorythmic drawplank setup](https://github.com/tradwiki/rythm-visuals-plank-5/blob/main/Media/2022-06-22-Rencontre-reseau-Photo-Ghislain-Jutras-18.gif)

rythm-visuals-plank-5 is an adaptation of [rythm-visuals-plank-4](https://github.com/tradwiki/rythm-visuals-plank-4). 
It transforms the reading of sensors embedded in a plank and transforms it into a midi and OSC signal to generate visuals.
This project showcases the use of analog piezo sensors and FSR sensors sending MIDI signals through a custom circuit that are translated in OSC through python and sent to a processing program to generate visuals.

## Getting started
* Connect the plank to the computer via USB.
* Run the script [analyse_signal.py](https://github.com/tradwiki/rythm-visuals-plank-5/blob/main/python_script/analyse_signal.py](https://github.com/tradwiki/rythm-visuals-plank-5/blob/main/Analyse_signal/Analyse_signal.py)
* Run Drawplank 2.0 script.

## Planche 5 - Read_Signals (Arduino Script)
[Planche_5_-_Read_Signals](https://github.com/tradwiki/rythm-visuals-plank-5/tree/main/Planche_5_-_Read_Signals) is designed to be uploaded to a Teensy (3.6) controller via the arduino IDE (see [Teensyduino documentation](https://www.pjrc.com/teensy/teensyduino.html)). The script sends data through the serial port to notify of an analog value spike on specified pins when the polled value is above the baseline by a certain threshold. The baseline is averaged over the previous readings while they remain below threshold. The threshold is adjusted based on signal stability to allow for more sensitive readings with more stable sensors. The script also sends and/or receives MIDI signals across USB using Teensy built-in support (see [Teensy USB MIDI documentation](https://www.pjrc.com/teensy/td_midi.html)).

<code style="color: Darkorange;">The arduino script is downloaded once in the Teensy of the plank.</code> 
### Configuration
Modify [/Planche_5_-_Read_Signals/config.h](https://github.com/tradwiki/rythm-visuals-plank-5/blob/main/Planche_5_-_Read_Signals/config.h) to modify thresholds, delays, notes, pins, debug.
#### Considerations
* Midi pin values are specific to the circuit design as presented
* Analyse_Signal configurations are dependant of MIDI note configurations
* Drawplank 2.0 configurations are dependant of the Analyse_Signal configurations 
* Thresholds, baselines and delays are the result of physical tests on the plank and may vary for specific constructions

## Analyse Signal (Python script)
![Analyse_signal screen capture](https://github.com/tradwiki/rythm-visuals-plank-5/blob/main/Media/Interface_scrip_python.png)

The python script translates MIDI signals coming from the plank to OSC signals. It interpretates different spikes and repetitions based on the signal received from the serial port as well as bpm.
The python script offers a visual interface of the incoming signals for troubleshooting through the pygame librairie.
### Configuration
[python_script/Sensor.py](https://github.com/tradwiki/rythm-visuals-plank-5/blob/main/Analyse_signal/Sensor.py) defines the OSC signal parameters as well as the sensor names.
By default, data is sent to the IP address 10.10.30.44 through port 5005.
#### Libraries for python
The installation of the following librairies is required for the python script.
* [python-osc](https://pypi.org/project/python-osc)
* [pygame](https://www.pygame.org/wiki/GettingStarted)

## Drawplank 2.0
![Drawplank screen capture](https://github.com/tradwiki/rythm-visuals-plank-5/blob/main/Media/Menu.png)
[Drawplank 2.0](https://github.com/tradwiki/rythm-visuals-plank-5/tree/main/DrawPlanck-2.0) was developped with the purpose of being used for video mapping through [Splash](https://sat.qc.ca/fr/splash/).
The program offers different modes of visual rendering of the plank's signal. 

<code style="color: Darkorange;">In order to use Drawplank 2.0, the python script must be running.</code> 
### Modes
Drawplank 2.0 offers 4 different modes
* Monitor
* Mondrian
* Raindrop
* Reboisons
### Use
* To select mode, the corresponding pad must be held.
* To exit a selected mode, the upper left pad must be held down.

## Device
![Insertion of the pcb in the plank](https://github.com/tradwiki/rythm-visuals-plank-5/blob/main/Media/Planche%200.4%20-%20insertion%20du%20pcb.jpg)

A custom pcb was printed for this project. The circuit uses 8 FSR sensors and 5 Piezo sensors.
One piezo sensor is used as a surface microphone and does not produce a digital signal.
The plank was cut using a CNC.
Further discription is available in the [/circuit](https://github.com/tradwiki/rythm-visuals-plank-5/tree/main/Circuit) folder.
