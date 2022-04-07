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
    int threshold;
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
};
