#include "Piezo.h"
//use this to make sure no false positives
//https://forum.arduino.cc/t/piezo-sensor-burst-reading-when-hit-please-help/214884/2

Piezo::Piezo() {

}

Piezo::Piezo(const int pin, const int note, const int index) {
  PIN = pin;
  NOTE = note;
  INDEX = index;
  WITH_MIDI = true;
  state = "IDLE";
  threshold = 100;
};

Piezo& Piezo::operator=(const Piezo&)
{
  return *this;
}


int Piezo::getPin() {
  return PIN;
}

int Piezo::getNote() {
  return NOTE;
}

int Piezo::getRead() {
  return sensorRead;
}

void Piezo::readResistance() {
  sensorRead = analogRead(PIN);

  if (sensorRead > threshold) {
    state = "ACTIVE";
    sendMidiSignal();
  }

  if (sensorRead < threshold && state == "ACTIVE") {
    state = "IDLE";
    sendMidiSignal();
  }
}

void Piezo::sendMidiSignal() {

  if (PIEZO_DEBUG) {
    printRead();
  }

  if (state == "ACTIVE") {
    usbMIDI.sendPolyPressure(NOTE, sensorRead, MIDI_CHANNEL);
    usbMIDI.send_now();
  }

  if (state == "IDLE") {
    Serial.println("FALLING");
    usbMIDI.sendNoteOff(NOTE, 0, MIDI_CHANNEL);
    usbMIDI.send_now();
  }
}

void Piezo::printRead() {
  Serial.print(NOTE);
  Serial.print(" ");
  Serial.print(state);
  Serial.print(" : ");
  Serial.println(sensorRead);
}
