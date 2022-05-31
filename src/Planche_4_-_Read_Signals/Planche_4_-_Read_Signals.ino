#include <limits.h>
#include "config.h"
#include "FSR.h"
#include "Piezo.h"
#include "Motor.h"



FSR* FSR_GRID[NUM_FSR_SENSORS];
//FSR* FSR_DROITE[NUM_FSR_SENSORS];
//FSR* FSR_GAUCHE[NUM_FSR_SENSORS];
Piezo* PIEZO_GRID[NUM_PIEZO_SENSORS];
Motor* MOTOR_GRID[NUM_MOTORS];

void setup() {
  Serial.begin(9600);
  fsrSetup(FSR_GRID, FSR_SENSOR_PINS, FSR_NOTES);
//  fsrSetup(FSR_DROITE, FSR_SENSOR_PINS_DROITE, FSR_NOTES_DROITE);
//  fsrSetup(FSR_GAUCHE, FSR_SENSOR_PINS_GAUCHE, FSR_NOTES_GAUCHE);
  piezoSetup(PIEZO_GRID, PIEZO_SENSOR_PINS, PIEZO_NOTES);
//  motorSetup(MOTOR_GRID);
  Serial.println("hello");
}

void loop() {
  piezoRead(PIEZO_GRID);
  piezoPrintReadActive(PIEZO_GRID);
//  sendPiezoMidi(PIEZO_GRID);
//
//  fsrRead(FSR_DROITE);
//  fsrPrintReadActive(FSR_DROITE);
//  fsrRead(FSR_GAUCHE);
//  fsrPrintReadActive(FSR_GAUCHE);
    fsrRead(FSR_GRID);
  fsrPrintReadActive(FSR_GRID); 
  sendFSRMidi(FSR_GRID);

//  readExternalMidi(MOTOR_GRID);
//  FSRtoMotor(FSR_GRID, MOTOR_GRID);   
  
  delay(10);
}
