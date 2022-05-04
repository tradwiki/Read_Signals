#include <limits.h>
#include "config.h"
#include "FSR.h"
#include "Piezo.h"
#include "Motor.h"

//FSR_GRID fsr_grid = FSR_GRID(FSR_SENSOR_PINS, FSR_NOTES);

FSR* FSR_GRID[NUM_FSR_SENSORS];
Piezo* PIEZO_GRID[NUM_PIEZO_SENSORS];
Motor* MOTOR_GRID[NUM_MOTORS];
//Piezo_Grid piezo_grid = Piezo_Grid(PIEZO_SENSOR_PINS, PIEZO_NOTES);

Piezo p1 = Piezo(PIEZO_SENSOR_PINS[0], PIEZO_NOTES[0], 0);
//FSR p1 = FSR(FSR_SENSOR_PINS[4], FSR_NOTES[4], 0);
void setup() {
  Serial.begin(9600);
  fsrSetup(FSR_GRID, FSR_SENSOR_PINS, FSR_NOTES);
  piezoSetup(PIEZO_GRID, PIEZO_SENSOR_PINS, PIEZO_NOTES);
  motorSetup(MOTOR_GRID);
  Serial.println("hello");
}

void loop() {
  piezoRead(PIEZO_GRID);
  piezoPrintReadActive(PIEZO_GRID);

  fsrRead(FSR_GRID);
  fsrPrintReadActive(FSR_GRID);
  
  delay(10);
}
