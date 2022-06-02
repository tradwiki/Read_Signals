#include <limits.h>
#include "config.h"
#include "FSR.h"
#include "Piezo.h"
#include "Motor.h"



FSR* FSR_GRID[NUM_FSR_SENSORS];
//FSR* FSR_DROITE[NUM_FSR_SENSORS];
//FSR* FSR_GAUCHE[NUM_FSR_SENSORS];
Piezo* PIEZO_GRID[NUM_PIEZO_SENSORS];

//  fsrSetup(FSR_DROITE, FSR_SENSOR_PINS_DROITE, FSR_NOTES_DROITE);
//  fsrSetup(FSR_GAUCHE, FSR_SENSOR_PINS_GAUCHE, FSR_NOTES_GAUCHE);
//  motorSetup(MOTOR_GRID);
void setup() {
  Serial.begin(9600);
  Serial.println("Welcome to read signals");
  fsrSetup(FSR_GRID, FSR_SENSOR_PINS, FSR_NOTES);
  piezoSetup(PIEZO_GRID, PIEZO_SENSOR_PINS, PIEZO_NOTES);
}

void loop() {
    piezoRead(PIEZO_GRID);
    piezoPrintReadActive(PIEZO_GRID);
  //  sendPiezoMidi(PIEZO_GRID);
  //
//
    fsrRead(FSR_GRID);
    fsrPrintReadActive(FSR_GRID);
    sendFSRMidi(FSR_GRID);

  //  readExternalMidi(MOTOR_GRID);
  //  FSRtoMotor(FSR_GRID, MOTOR_GRID);

}

void fsrSetup(FSR** FSR_GRID, const int* sensor_pins, const int* notes) {
  for (int i = 0; i < NUM_FSR_SENSORS; i++) {
    FSR_GRID[i] = new FSR(sensor_pins[i], notes[i], i);
    FSR_GRID[i]->calibrate();
//    delay(50);
  }
}
