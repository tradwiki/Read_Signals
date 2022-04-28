#include "config.h"
#include "FSR.h"

//TODO: take the external notes and translate it to the FSR notes and therefore the motors

int noteToSensor(int note){
}

int noteToSensor(FSR** FSR_GRID, int note) {
  for (int i = 0; i < NUM_FSR_SENSORS; i++) {
    if (FSR_NOTES[i] == note) {
      return i;
    }
  }
  return -1;
}

void MotorOff() {
  if (NUM_MOTORS > 0) {
    pinMode(LED_PIN, OUTPUT);

    for (int motor = 0; motor < NUM_MOTORS; motor++) {
      pinMode(MOTOR_PINS[motor], OUTPUT);
      digitalWrite(MOTOR_PINS[motor], LOW);
    }
  }
}

void MotorOff(int motor) {
  if (NUM_MOTORS > 0) {
    pinMode(LED_PIN, OUTPUT);

    pinMode(MOTOR_PINS[motor], OUTPUT);
    digitalWrite(MOTOR_PINS[motor], LOW);

  }
}

void MotorOn() {
  if (NUM_MOTORS > 0) {
    pinMode(LED_PIN, OUTPUT);

    for (int motor = 0; motor < NUM_MOTORS; motor++) {
      pinMode(MOTOR_PINS[motor], OUTPUT);
      digitalWrite(MOTOR_PINS[motor], HIGH);
    }
  }
}

void MotorOn(int motor) {
  if (NUM_MOTORS > 0) {
    pinMode(LED_PIN, OUTPUT);

    pinMode(MOTOR_PINS[motor], OUTPUT);
    digitalWrite(MOTOR_PINS[motor], HIGH);
  }
}

void noteToMotor(int note) {
  if (NUM_MOTORS > 0) {
    pinMode(LED_PIN, OUTPUT);

    for (int motor = 0; motor < NUM_MOTORS; motor++) {
      pinMode(MOTOR_PINS[motor], OUTPUT);
      digitalWrite(MOTOR_PINS[motor], HIGH);
    }
  }
}

void readMidi() {
  if (usbMIDI.read()) {
    if (usbMIDI.getType() == usbMIDI.NoteOn) {

      //      Serial.println("MIDI ON");
      //      delay(10);

      byte note = usbMIDI.getData1();
      byte velocity = usbMIDI.getData2();
      //
      //      Serial.println(note);
      //      delay(10);
      //      Serial.println(velocity);
      //      delay(10);
      int sensorIndex = noteToSensor((int) note);
      if ( sensorIndex != -1) {
        rising(sensorIndex, (int) velocity, false);
        lastExternalMidiOn[sensorIndex] = micros();
      }
    } else if (usbMIDI.getType() == usbMIDI.NoteOff) {
      //
      //      Serial.println("MIDI OFF");
      //      delay(10);

      byte note = usbMIDI.getData1();
      //      Serial.println(note);
      //      delay(10);
      int sensorIndex = noteToSensor((int) note);
      if ( sensorIndex != -1) {
        falling(sensorIndex, false);
        lastExternalMidiOn[sensorIndex] = 0;
      }
    }
  }
}
