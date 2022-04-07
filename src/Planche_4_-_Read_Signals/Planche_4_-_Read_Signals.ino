#include <limits.h>
#include "config.h"
#include "FSR_GRID.h"
#include "Piezo_Grid.h"

FSR_GRID fsr_grid = FSR_GRID(FSR_SENSOR_PINS, FSR_NOTES);

//Piezo_Grid piezo_grid = Piezo_Grid(PIEZO_SENSOR_PINS, PIEZO_NOTES);

Piezo p1 = Piezo(PIEZO_SENSOR_PINS[0], PIEZO_NOTES[0], 0);

void setup() {
  Serial.begin(9600);
  fsr_grid.calibrateAll();
}

void loop() {
//  fsr_grid.readResistance();
//  fsr_grid.printReadActive();
//  fsr_grid.sendMidiSignal();

//  piezo_grid.readResistance();
p1.readResistance();
  delay(10);
}
