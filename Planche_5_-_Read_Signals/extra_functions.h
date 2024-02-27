#include "config.h"
#include "FSR.h"
#include "Piezo.h"
#include "Motor.h"

void FSRtoMotor(FSR** FSR_GRID, Motor** MOTOR_GRID){

    for (int currFSR = 0; currFSR < NUM_FSR_SENSORS; currFSR++){
      if (FSR_GRID[currFSR]->getState() == "RISING"){
        for (int currMotor = 0; currMotor < NUM_MOTORS; currMotor++){
          MOTOR_GRID[currMotor] -> receiveNote(FSR_GRID[currFSR]->getNote(), FSR_GRID[currFSR] -> getScaledVelocity());
        }
      }
    }
}


void readExternalMidi(Motor** MOTOR_GRID) {
  if (usbMIDI.read()) {

    byte note = usbMIDI.getData1();
    byte velocity = usbMIDI.getData2();

    if (usbMIDI.getType() == usbMIDI.NoteOn) {

      for (int i = 0; i < NUM_MOTORS; i++) {
        MOTOR_GRID[i]->receiveNote(note, velocity);
      }

      if (MIDI_RECEIVE_DEBUG) {
        Serial.print("RECEIVED MIDI NOTE ON: ");
        Serial.print(note);
        Serial.print(" : ");
        Serial.println(velocity);
      }


    } else if (usbMIDI.getType() == usbMIDI.NoteOff) {

      for (int i = 0; i < NUM_MOTORS; i++) {
        MOTOR_GRID[i]->receiveNote(note, velocity);
      }
      Serial.println(note);
    }
  }
}
