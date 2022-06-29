#include "FSR.h"

FSR::FSR() {

}

FSR::FSR(const int pin, const int note, const int index) {
  PIN = pin;
  NOTE = note;
  INDEX = index;
  WITH_MIDI = true;
  IS_CLOCKING_PAD = false;
  baseline = 0;
  jumpThreshold = 0;
  tapsToIgnore = 0;
  state = "IDLE";
};

FSR& FSR::operator=(const FSR&)
{
  return *this;
}

int FSR::getPin() {
  return this->PIN;
}

int FSR::getNote() {
  return NOTE;
}

String FSR::getState() {
  return state;
}

int FSR::getSensorReading() {
  return sensorReading;
}

int FSR::getBaseline() {
  return baseline;
}

int FSR::getVelocity() {
  return velocity;
}

int FSR::getScaledVelocity() {
  return scaledVelocity;
}

///

void FSR::calibrate() {
  Serial.print("Calibration du FSR ");
  Serial.print(INDEX);
  Serial.print(" NOTE ");
  Serial.print(NOTE);
  Serial.print(".");
  delay(200);
  Serial.print(".");
  delay(200);
  Serial.print(".");
  baseline = analogRead(PIN);
  jumpThreshold = (FSR_MIN_THRESHOLD + FSR_MAX_THRESHOLD) / 2;
  Serial.println("terminé!");
}

void FSR::readResistance() {
  sensorReading = analogRead(PIN);
  distanceAboveBaseline = max(0, sensorReading - baseline);

  //make state idle by default
  state = "IDLE";

  if (distanceAboveBaseline >= jumpThreshold) {

    if (sustainCount == 0) {
      state = "WAITING";
      updateSustainCount();
    }
    //RISING
    else if (sustainCount == 1) {
      //WAIT
      //waiting is caused by velocity the velocity offset delay
      if (toWaitBeforeRising > 0) {
        state = "WAITING";
        updateRemainingTime(toWaitBeforeRising, lastRisingTime);
      }
      //SIGNAL
      else {
        //        RISING
        //        rising(currentSensor, distanceAboveBaseline);
        velocity = distanceAboveBaseline;
        rising();
        state = "RISING";
        //        sendMidiSignal();
      }
    }
    //SUSTAINING
    else {
      //RESET
      if (sustainCount > MAX_CONSECUTIVE_SUSTAINS) {
        sustainReset();
      }
      //WAIT
      else if (toWaitBeforeSustaining > 0) {
        updateRemainingTime(toWaitBeforeSustaining, lastSustainingTime);
      }
      //SIGNAL
      else {
        velocity = distanceAboveBaseline;
        state = "SUSTAINED";
        sustained();
      }
    }
  }


  else {
    //FALLING
    if (justJumped) {
      //WAIT
      if (toWaitBeforeFalling) {
        updateRemainingTime(toWaitBeforeFalling, lastRisingTime);
        state = "WAITING";
      }
      //SIGNAL
      else {
        state = "FALLING";
        //        sendMidiSignal();
        falling();
      }
    }
    //BASELINING
    else {
      //reset jump counter
      sustainCount = 0;

      //RESET
      if (baselineBufferIndex > (BASELINE_BUFFER_SIZE - 1)) {
        baselineReset();
      }
      //WAIT
      else if (toWaitBeforeBaseline > 0) {
        state = "WAITING";
        updateRemainingTime(toWaitBeforeBaseline, lastBaselineTime);
      }
      //SAMPLE
      else {
        state = "WAITING";
        baselineBuffer[baselineBufferIndex] = sensorReading;
        baselineBufferIndex++;

        //reset timer
        lastBaselineTime = micros();
        toWaitBeforeBaseline = BASELINE_SAMPLE_DELAY;
      }
    }
  }
}


void FSR::jumping() {

}


void FSR::rising() {
  lastRisingTime = micros();
  toWaitBeforeFalling = NOTE_ON_DELAY;

  lastSustainingTime = micros();
  toWaitBeforeSustaining = SUSTAIN_DELAY;

  justJumped = true;
  sustainCount++;
}

void FSR::falling() {
  lastRisingTime = micros();
  toWaitBeforeRising = NOTE_OFF_DELAY;

  //wait before buffering baseline
  //this is to ignore the sensor "blowback" (erratic readings after jumps)
  //and remove falling edge portion of signal that is below threshold
  lastBaselineTime = micros();
  toWaitBeforeBaseline = BASELINE_BLOWBACK_DELAY;

  justJumped = false;

  //backtrack baseline count to remove jump start
  //(might not do anything if we just updated baseline)
  baselineBufferIndex = max( 0, baselineBufferIndex - RETRO_JUMP_BLOWBACK_SAMPLES);

  //reset jump counter
  sustainCount = 0;
}

void FSR::sustained() {
  lastSustainingTime = micros();
  toWaitBeforeSustaining = SUSTAIN_DELAY;
  sustainCount++;
}

void FSR::baselining() {
}


void FSR::sample() {

  baselineBuffer[baselineBufferIndex] = sensorReading;
  baselineBufferIndex++;

  //reset timer
  lastBaselineTime = micros();
  toWaitBeforeBaseline = BASELINE_SAMPLE_DELAY;
}

int FSR::updateThreshold(int (&baselineBuff)[BASELINE_BUFFER_SIZE], int oldBaseline, int oldThreshold) {

  int varianceFromBaseline = varianceFromTarget(baselineBuff, BASELINE_BUFFER_SIZE, oldBaseline);
  int newThreshold = constrain(varianceFromBaseline, FSR_MIN_THRESHOLD, FSR_MAX_THRESHOLD);

  int deltaThreshold = newThreshold - oldThreshold;
  if (deltaThreshold < 0) {
    //split the difference to slow down threshold becoming more sensitive
    newThreshold = constrain(oldThreshold + ((deltaThreshold) / 4), FSR_MIN_THRESHOLD, FSR_MAX_THRESHOLD);
  }

  return newThreshold;
}

void FSR::updateSustainCount() {
  if (toWaitBeforeRising > 0) {
    updateRemainingTime(toWaitBeforeRising, lastRisingTime);
  }
  //TRIGGER DELAY
  else {
    lastRisingTime = micros();
    toWaitBeforeRising = NOTE_VELOCITY_DELAY;
    sustainCount++;
  }
}

void FSR::sendMidiSignal() {
  if (WITH_MIDI) {
    if (state == "RISING") {
      Serial.println("RISING");
      int maxVelocity = FSR_MAX_READING - baseline;
      int constrainedVelocity = constrain(velocity, jumpThreshold, maxVelocity);
      scaledVelocity =  map(constrainedVelocity, jumpThreshold, maxVelocity, 1, 127);
      usbMIDI.sendNoteOn(NOTE, scaledVelocity, MIDI_CHANNEL);

      if (IS_CLOCKING_PAD) {
        usbMIDI.sendRealTime(usbMIDI.Clock);
        usbMIDI.send_now();
      }
    }
    else if (state == "SUSTAINED") {
      Serial.println("SUSTAINED");
      usbMIDI.sendPolyPressure(NOTE, map(constrain(velocity, jumpThreshold, 512), jumpThreshold, 512, 64, 127), MIDI_CHANNEL);
      usbMIDI.send_now();
    }

    else if (state == "FALLING") {
      Serial.println("FALLING");
      usbMIDI.sendNoteOff(NOTE, 0, MIDI_CHANNEL);
      usbMIDI.send_now();
    }

    while (usbMIDI.read()) {}
  }
}

void FSR::printRead() {
  Serial.print(NOTE);
  Serial.print(" ");
  Serial.print(state);
  Serial.print(" : ");
  Serial.print(jumpThreshold);
  Serial.print(" : ");
  Serial.print(sensorReading);
  Serial.print(" : ");
  Serial.println(velocity);
}

void FSR::printReadActive() {
  if (state == "RISING" || state == "SUSTAINED") {
    printRead();
  }
}

bool FSR::isActive() {
  return state == "RISING" || state == "SUSTAINED";
}

void FSR::sustainReset() {
  baseline = sensorReading;

  //reset counters
  baselineBufferIndex = 0;
  sustainCount = 0;
}


void FSR::baselineReset() {
  jumpThreshold = updateThreshold(baselineBuffer, baseline, jumpThreshold);
  int maxBaseline = FSR_MAX_READING - jumpThreshold - FSR_MIN_JUMPING_RANGE;
  baseline = min(bufferAverage(baselineBuffer, BASELINE_BUFFER_SIZE), maxBaseline);

  //reset counter
  baselineBufferIndex = 0;
}

int FSR::varianceFromTarget(int * a, int aSize, int target) {
  unsigned long sum = 0;
  int i;
  for (i = 0; i < aSize; i++) {
    //makes sure we dont bust when filling up sum
    int toAdd = pow( (a[i] - target), 2);
    if (sum < ULONG_MAX - toAdd) {
      sum += toAdd;
    }
    else {
      Serial.print(NOTE);
      Serial.println(" WARNING: Exceeded ULONG_MAX while running varianceFromTarget(). Check your parameters to ensure buffers aren't too large.");
      delay(1000);
      break;
    }
  }

  return (int) (sum / i);
}

void FSR::updateRemainingTime(unsigned long (&left), unsigned long (&last)) {
  unsigned long thisTime = micros();
  unsigned long deltaTime = thisTime - last;

  if (deltaTime < left) {
    left -= deltaTime;
  } else {
    left = 0;
  }

  last = thisTime;
}


int FSR::bufferAverage(int * a, int aSize) {
  unsigned long sum = 0;
  int i;
  for (i = 0; i < aSize; i++) {
    //makes sure we dont bust when filling up sum
    if (sum < (ULONG_MAX - a[i])) {
      sum += a[i];
    }
    else {
      Serial.print(NOTE);
      Serial.println(" WARNING: Exceeded ULONG_MAX while running bufferAverage(). Check your parameters to ensure buffers aren't too large.");
      delay(1000);
      break;
    }
  }
  return (int) (sum / i);
}

Pad::Pad(const int note, const int index, FSR* fsr0, FSR* fsr1) {
  NOTE = note;
  INDEX = index;
  state = "IDLE";
  sensors[0] = fsr0;
  sensors[1] = fsr1;
}

int Pad::getNote() {
  return NOTE;
}

String Pad::getState() {
  return state;
}

//if FSR not specified, send average of both reads
int Pad::getReading() {
  return (read[0] + read[1]) / 2;
}

int Pad::getReading(int n) {
  if (n < 2)  {
    return read[n];
  }

  else {
    return -1;
  }
}

void Pad::sendMidiSignal() {
  if (WITH_MIDI) {
    if (state == "RISING") {
      Serial.println("RISING");

      int scaledMean = 0;
      for (int i = 0; i < 2; i ++) {
        scaledMean += sensors[i]->getScaledVelocity();
      }
      scaledMean = scaledMean / 2;
      usbMIDI.sendNoteOn(NOTE, scaledMean, MIDI_CHANNEL);
    }
    else if (state == "SUSTAINED") {
      Serial.println("SUSTAINED");
      int scaledMean = 0;
      for (int i = 0; i < 2; i ++) {
        scaledMean += sensors[i]->getScaledVelocity();
      }
      usbMIDI.sendPolyPressure(NOTE, scaledMean, MIDI_CHANNEL);
      usbMIDI.send_now();
    }

    else if (state == "FALLING") {
      Serial.println("FALLING");
      usbMIDI.sendNoteOff(NOTE, 0, MIDI_CHANNEL);
      usbMIDI.send_now();
    }
  }
}
bool Pad::isActive() {
  return (state == "RISING" || state == "SUSTAINED");
}

void Pad::getRead() {
  if (state == "IDLE") {

    if (sensors[0]->isActive() && sensors[1]->isActive()) {
      state = "RISING";
      sendMidiSignal();
      Serial.print("Pad ");
      Serial.print(INDEX);
      Serial.print(": ");
      Serial.println(state);
    }

  }

  else if (sensors[0]->getState() == "WAITING" || sensors[1]->getState() == "WAITING") {
    state = "WAITING";
  }

  else {
    //    turn off if one of the sensors is off
    if (sensors[0]->getState() == "FALLING" || sensors[1]->getState() == "FALLING") {
      state = "FALLING";
      sendMidiSignal();
      state = "IDLE";
    }

    if (sensors[0]->getState() == "IDLE" || sensors[1]->getState() == "IDLE") {
      state = "FALLING";
      sendMidiSignal();
      state = "IDLE";
    }

    else if (state == "RISING") {
      state = "SUSTAINED";
      sendMidiSignal();
      Serial.print("Pad ");
      Serial.print(INDEX);
      Serial.print(": ");
      Serial.println(state);
    }
  }
}

void fsrSetup(FSR** FSR_GRID, const int* sensor_pins, const int* notes) {
  for (int i = 0; i < NUM_FSR_SENSORS; i++) {
    FSR_GRID[i] = new FSR(sensor_pins[i], notes[i], i);
    FSR_GRID[i]->calibrate();
  }
}

void fsrRead(FSR** FSR_GRID) {
  for (int i = 0; i < NUM_FSR_SENSORS; i++) {
    FSR_GRID[i]->readResistance();
  }
}

void fsrRead(FSR** FSR_GRID, int sensor) {
  FSR_GRID[sensor]->readResistance();
}

void fsrPrintReadActive(FSR** FSR_GRID) {
  for (int i = 0; i < NUM_FSR_SENSORS; i++) {
    FSR_GRID[i]->printReadActive();
  }
}

void fsrPrintReadActive(FSR** FSR_GRID, int sensor) {
  FSR_GRID[sensor]->printReadActive();
}


void sendFSRMidi(FSR** FSR_GRID) {
  for (int sensor = 0; sensor < NUM_FSR_SENSORS; sensor++) {
    FSR_GRID[sensor]->sendMidiSignal();
  }
}

void sendFSRMidi(FSR** FSR_GRID, int sensor) {
  FSR_GRID[sensor]->sendMidiSignal();
}

void padRead(Pad** PAD_GRID) {
  for (int i = 0; i < NUM_PADS; i++) {
    PAD_GRID[i]->getRead();
  }
}

void fsrPrintReadInRows(FSR** FSR_GRID) {
  bool doIPrint = false;
  // print all values if one sensor is active
  for (int i = 0; i < NUM_FSR_SENSORS; i++) {
    if (FSR_GRID[i]->isActive()) {
      doIPrint = true;
      Serial.println(FSR_GRID[i]->getState());
      break;
    }
  }

  if (doIPrint) {
    for (int i = 0; i < NUM_FSR_SENSORS; i++) {
      Serial.print(FSR_GRID[i]->getNote());
      Serial.print(" : ");
      if (FSR_GRID[i]->getSensorReading() < 10) {
        Serial.print("  ");
      }

      if (FSR_GRID[i]->getSensorReading() >= 10 && FSR_GRID[i]->getSensorReading() < 100) {
        Serial.print(" ");
      }
      Serial.print(FSR_GRID[i]->getSensorReading());
      Serial.print(" | ");
    }
    Serial.println();
  }
}

void padSetup(Pad** PAD_GRID, FSR** FSR_GRID, const int* notes) {
  for (int i = 0; i < NUM_PADS; i++) {
    PAD_GRID[i] = new Pad(notes[i], i, FSR_GRID[i * 2], FSR_GRID[i * 2 + 1]);
  }
}
