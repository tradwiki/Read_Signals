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
    int threshold = 20;
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

void piezoGridSetup(Piezo** PIEZO_GRID, const int* sensor_pins, const int* notes);
void piezoGridRead(Piezo** PIEZO_GRID);
void piezoGridRead(Piezo** PIEZO_GRID, int sensor);
void piezoGridPrintReadActive(Piezo** PIEZO_GRID);
void piezoGridPrintReadActive(Piezo** PIEZO_GRID, int sensor);
