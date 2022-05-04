#include "Motor.h"
#include "FSR.h"

Motor::Motor() {}

Motor::Motor(const int pin, const int* notes, const int index) {
  PIN = pin;
  NOTES = notes;
  INDEX = index;
  state = "OFF";
}

Motor& Motor::operator=(const Motor&) {
  return *this;
}

int Motor::getPin() {
  return PIN;
}

const int* Motor::getNotes() {
  return NOTES;
}

int Motor::getIndex() {
  return INDEX;
}

String Motor::getState() {
  return state;
}

void Motor::motorOn() {
  pinMode(PIN, OUTPUT);
  digitalWrite(PIN, HIGH);
  state = "ON";
}

void Motor::motorOff() {
  pinMode(PIN, OUTPUT);
  digitalWrite(PIN, LOW);
  state = "OFF";
}

void Motor::receiveNote(int note, int value) {
  bool rightNote = false;

  for (int i = 0; i < NUM_NOTES; i++) {
    if (NOTES[i] == note) {
      rightNote = true;
    }
  }

  if (rightNote) {
    if (state == "OFF" && value > MOTOR_THRESHOLD) {
      motorOn();
    }

    if (state == "ON" && value < MOTOR_THRESHOLD) {
      motorOff();
    }
  }

}

void Motor::update() {

  //limiter so the motor doesn't stay on too long
  if ((millis() - timeStamp) >= MAX_MOTOR_PULSE_DURATION) {
    motorOff();
    timeStamp = millis();
  }

}
