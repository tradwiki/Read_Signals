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
  //  default to rogue to get rid of risidual charge
  state = "IDLE";
//  threshold = 5;
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

//void Piezo::readResistance(){
//  prevSensorRead = sensorRead;
//  sensorRead = analogRead(PIN);
//
//  if (sensorRead > threshold){
//    sendMidiSignal();
//    state = "ACTIVE";
//  }
//
//  if (sensorRead <= threshold && state == "ACTIVE"){
//    sendMidiSignal(); 
//    state = "IDLE";
//  }
//}
//
void Piezo::readResistance() {
  prevSensorRead = sensorRead;
  sensorRead = analogRead(PIN);

  if (sensorRead > threshold && state != "ROGUE") {

    if (state == "ACTIVE") {
      state = "SUSTAINED";
    }

    else {
      state = "ACTIVE";
    }

    sendMidiSignal();
    timer++;
    // cut out the signal if there is a risidual charge
    if (timer > MAX_PIEZO_TIME) {
      state = "IDLE";
      sendMidiSignal();
      state = "ROGUE";
    }
  }

  else  if (sensorRead < threshold && state != "IDLE") {
    state = "IDLE";
    timer = 0;
    sendMidiSignal();
  }
}

void Piezo::sendMidiSignal() {


//  int mappedRead =  map(sensorRead, 0,  1023, 0, 127);
  int mappedRead = sensorRead;

  if (PIEZO_DEBUG) {
    printRead();
  }

  if (state == "ACTIVE") {
    usbMIDI.sendNoteOn(NOTE, mappedRead, MIDI_CHANNEL);
    usbMIDI.send_now();
  }

  else if (state == "SUSTAINED") {
    Serial.println("SUSTAINED");
    usbMIDI.sendPolyPressure(NOTE, mappedRead, MIDI_CHANNEL);
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

void Piezo::printReadActive() {
  if (state == "ACTIVE") {
    printRead();
  }
}

void piezoSetup(Piezo** PIEZO_GRID, const int* sensor_pins, const int* notes) {
  for (int i = 0; i < NUM_PIEZO_SENSORS; i++) {
    PIEZO_GRID[i] = new Piezo(sensor_pins[i], notes[i], i);
    //    PIEZO_GRID[i]->calibrate();
  }
}

void piezoRead(Piezo** PIEZO_GRID) {
  for (int i = 0; i < NUM_PIEZO_SENSORS; i++) {
    PIEZO_GRID[i]->readResistance();
  }
}

void piezoRead(Piezo** PIEZO_GRID, int sensor) {
  PIEZO_GRID[sensor]->readResistance();
}

void piezoPrintRead(Piezo** PIEZO_GRID) {
  for (int i = 0; i < NUM_PIEZO_SENSORS; i++) {
    PIEZO_GRID[i]->printRead();
  }
}

void piezoPrintRead(Piezo** PIEZO_GRID, int sensor) {
  PIEZO_GRID[sensor]->printRead();
}

void piezoPrintReadActive(Piezo** PIEZO_GRID) {
  for (int i = 0; i < NUM_PIEZO_SENSORS; i++) {
    PIEZO_GRID[i]->printReadActive();
  }
}

void piezoPrintReadActive(Piezo** PIEZO_GRID, int sensor) {
  PIEZO_GRID[sensor]->printReadActive();
}
