#include <limits.h>
#include "config.h"
#include "FSR.h"
#include "Piezo.h"
#include "Motor.h"



FSR* FSR_GRID[NUM_FSR_SENSORS];
Piezo* PIEZO_GRID[NUM_PIEZO_SENSORS];
Pad* PAD_GRID[NUM_PADS];
//  motorSetup(MOTOR_GRID);
void setup() {
  Serial.begin(9600);
  Serial.println("Welcome to read signals");
  fsrSetup(FSR_GRID, FSR_SENSOR_PINS, FSR_NOTES_1);
  piezoSetup(PIEZO_GRID, PIEZO_SENSOR_PINS, PIEZO_NOTES);

  if (MIDI_MODE == 0){
    padSetup(PAD_GRID, FSR_GRID, FSR_NOTES_0);
  }
}

void loop() {

  if (MIDI_MODE == 0){
    fsrRead(FSR_GRID);
    padRead(PAD_GRID);
//    fsrPrintReadInRows(FSR_GRID);
//    fsrRead(FSR_GRID);
//    padSendMidi(FSR_GRID);
//    padPrintRead(FSR_GRID);
  }

  else if (MIDI_MODE == 1) {
    piezoRead(PIEZO_GRID);
    piezoPrintReadInRows(PIEZO_GRID);

    fsrRead(FSR_GRID);
    fsrPrintReadActive(FSR_GRID);
    sendFSRMidi(FSR_GRID);
  }

  //  readExternalMidi(MOTOR_GRID);
  //  FSRtoMotor(FSR_GRID, MOTOR_GRID);
  delay(10);
}
