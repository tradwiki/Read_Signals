#include <limits.h>
#include "config.h"
#include "FSR_GRID.h"
//#include "FSR.H"

FSR_GRID fsr_grid = FSR_GRID(FSR_SENSOR_PINS, FSR_NOTES);

void setup() {
  Serial.begin(9600);
  fsr_grid.calibrateAll();
}

void loop() {
  fsr_grid.readResistance();
  fsr_grid.printReadActive();
  fsr_grid.sendMidiSignal();
  delay(10);
}
