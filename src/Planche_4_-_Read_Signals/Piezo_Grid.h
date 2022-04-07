#pragma once
#include "config.h"
#include "Piezo.h"

class Piezo_Grid {
  private:

  Piezo* sensors[NUM_PIEZO_SENSORS];
  
  public:
  Piezo_Grid();
  Piezo_Grid(const int* sensor_pins, const int* notes);
  Piezo_Grid& operator=(const Piezo_Grid&);
  
  void readResistance();
  void readResistance(int currSensor);

  void sendMidiSignal();
  void sendMidiSignal(int currSensor);
  
  void printRead();
  void printRead(int currSensor);

};
