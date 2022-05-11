#include <limits.h>
#include "config.h"
#include "FSR.h"
#include "Piezo.h"
#include "Motor.h"
#include "extra_functions.h"


FSR* FSR_GRID[NUM_FSR_SENSORS];
Piezo* PIEZO_GRID[NUM_PIEZO_SENSORS];
Motor* MOTOR_GRID[NUM_MOTORS];

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
//  sendPiezoMidi(PIEZO_GRID);

//  fsrRead(FSR_GRID);
//  fsrPrintReadActive(FSR_GRID); 
//  sendFSRMidi(FSR_GRID);

//  readExternalMidi(MOTOR_GRID);
//  FSRtoMotor(FSR_GRID, MOTOR_GRID);   
  
  delay(10);
}
