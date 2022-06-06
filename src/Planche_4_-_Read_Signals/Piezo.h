#pragma once
#include "config.h"
#include "Arduino.h"

class Piezo {

  private:
    int PIN;
    int NOTE;
    int INDEX;
    bool WITH_MIDI;
    int sensorRead;
    int prevSensorRead;
    int timer;
    int threshold = 10;
    String state;
    
  public:
    Piezo();
    Piezo(const int pin, const int note, const int index);
    Piezo& operator=(const Piezo&);

    int getPin();
    int getNote();
    int getRead();

    void readResistance();
    void sendMidiSignal();
    void printRead();
    void printReadActive();
};

void piezoSetup(Piezo** PIEZO_GRID, const int* sensor_pins, const int* notes);
void piezoRead(Piezo** PIEZO_GRID);
void piezoRead(Piezo** PIEZO_GRID, int sensor);
void piezoPrintReadActive(Piezo** PIEZO_GRID);
void piezoPrintReadActive(Piezo** PIEZO_GRID, int sensor);

void sendPiezoMidi(Piezo** PIEZO_GRID){
  for (int sensor = 0; sensor < NUM_PIEZO_SENSORS; sensor++){
    PIEZO_GRID[sensor]->sendMidiSignal();
  }
}

void sendPiezoMidi(Piezo** PIEZO_GRID, int sensor){
  PIEZO_GRID[sensor]->sendMidiSignal();
}
