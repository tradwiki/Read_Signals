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
    void printNotes();
};

void motorSetup(Motor** MOTOR_GRID){
  for (int i = 0; i < NUM_MOTORS; i++){
    MOTOR_GRID[i] = new Motor(MOTOR_PINS[i], MOTOR_NOTES[i], i);
    MOTOR_GRID[i] -> motorOff();
  }
}
