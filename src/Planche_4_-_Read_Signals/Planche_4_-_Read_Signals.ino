#include <limits.h>
#include "config.h"
#include "FSR.h"
#include "Piezo.h"

//FSR_GRID fsr_grid = FSR_GRID(FSR_SENSOR_PINS, FSR_NOTES);

FSR* FSR_GRID[NUM_FSR_SENSORS];
Piezo* PIEZO_GRID[NUM_PIEZO_SENSORS];
//Piezo_Grid piezo_grid = Piezo_Grid(PIEZO_SENSOR_PINS, PIEZO_NOTES);

Piezo p1 = Piezo(PIEZO_SENSOR_PINS[0], PIEZO_NOTES[0], 0);
//FSR p1 = FSR(FSR_SENSOR_PINS[4], FSR_NOTES[4], 0);
void setup() {
  Serial.begin(9600);
  fsrGridSetup(FSR_GRID, FSR_SENSOR_PINS, FSR_NOTES);
  piezoGridSetup(PIEZO_GRID, PIEZO_SENSOR_PINS, PIEZO_NOTES);
  Serial.println("hello");
}

void loop() {
//  fsrGridRead(FSR_GRID);
//  fsrGridPrintReadActive(FSR_GRID);
//  p1.readResistance();
//  p1.printReadActive();
    piezoGridRead(PIEZO_GRID);
    piezoGridPrintReadActive(PIEZO_GRID);
  delay(10);
}
