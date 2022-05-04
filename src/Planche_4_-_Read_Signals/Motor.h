#pragma once
#include "config.h"
#include "Arduino.h"

class Motor {
  private:
    int PIN;
    const int* NOTES;
    int INDEX;
    String state;
    unsigned long timeStamp;
    int NUM_NOTES = 2;
    
  public:
    Motor();
    Motor(const int pin, const int* notes, const int index);
    Motor& operator=(const Motor&);

    int getPin();
    const int* getNotes();
    int getIndex();
    String getState();

    void motorOn();
    void motorOff();
    void receiveNote(int note, int value);
    void update();
};

void motorSetup(Motor** MOTOR_GRID){
  
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
