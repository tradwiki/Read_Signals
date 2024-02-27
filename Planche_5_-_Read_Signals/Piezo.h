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
    int threshold;
    String state;
    
  public:
    Piezo();
    Piezo(const int pin, const int note, const int index);
    Piezo& operator=(const Piezo&);

    int getPin();
    int getNote();
    int getRead();
    String getState();

    void readResistance();
    void sendMidiSignal();
    void printRead();
    void printReadActive();
};

void piezoSetup(Piezo** PIEZO_GRID, const int* sensor_pins, const int* notes);
void piezoRead(Piezo** PIEZO_GRID);
void piezoRead(Piezo** PIEZO_GRID, int sensor);
void piezoPrintRead(Piezo** PIEZO_GRID);
void piezoPrintRead(Piezo** PIEZO_GRID, int sensor);
void piezoPrintReadActive(Piezo** PIEZO_GRID);
void piezoPrintReadActive(Piezo** PIEZO_GRID, int sensor);
void piezoPrintReadInRows(Piezo** PIEZO_GRID);

void sendPiezoMidi(Piezo** PIEZO_GRID){
  for (int sensor = 0; sensor < NUM_PIEZO_SENSORS; sensor++){
    PIEZO_GRID[sensor]->sendMidiSignal();
  }
}

void sendPiezoMidi(Piezo** PIEZO_GRID, int sensor){
  PIEZO_GRID[sensor]->sendMidiSignal();
}

void piezoPrintReadInRows(Piezo** PIEZO_GRID){
  bool doIPrint = false;

  for (int i = 0; i < NUM_PIEZO_SENSORS; i++){
    if (PIEZO_GRID[i]->getState() != "IDLE"){
      doIPrint = true;
    }
  }

  if (doIPrint){
  for (int i = 0; i < NUM_PIEZO_SENSORS; i++){
    Serial.print(PIEZO_GRID[i]->getNote());
    Serial.print(" : ");
    if (PIEZO_GRID[i]->getRead() < 10){
      Serial.print("  ");
    }

    if (PIEZO_GRID[i]->getRead() >= 10 && PIEZO_GRID[i]->getRead() < 100){
      Serial.print(" ");
    }
    Serial.print(PIEZO_GRID[i]->getRead());
    Serial.print(" | ");
  }
  Serial.println();
  }
}
