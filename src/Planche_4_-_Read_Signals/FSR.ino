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

int FSR::getSensorReading(){
  return sensorReading;
}

void FSR::calibrate() {
  baseline = analogRead(PIN);
  jumpThreshold = (MIN_THRESHOLD + MAX_THRESHOLD) / 2;
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
  maxVelocity = MAX_READING - baseline;
  constrainedVelocity = constrain(velocity, jumpThreshold, maxVelocity);
  scaledVelocity =  map(constrainedVelocity, jumpThreshold, maxVelocity, 64, 127);

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
  int newThreshold = constrain(varianceFromBaseline, MIN_THRESHOLD, MAX_THRESHOLD);

  int deltaThreshold = newThreshold - oldThreshold;
  if (deltaThreshold < 0) {
    //split the difference to slow down threshold becoming more sensitive
    newThreshold = constrain(oldThreshold + ((deltaThreshold) / 4), MIN_THRESHOLD, MAX_THRESHOLD);
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

void FSR::printRead(){
    Serial.print(NOTE);
    Serial.print(" ");
    Serial.print(state);
    Serial.print(" : ");
    Serial.print(jumpThreshold);
    Serial.print(" : ");
    Serial.print(sensorReading);
    Serial.print(" , ");
    Serial.print(velocity);
    Serial.print(",");
    Serial.println(scaledVelocity);
}

void FSR::printReadActive(){
  if (state == "RISING" || state == "SUSTAINED"){
    printRead();
  }
}

void FSR::sustainReset() {
  baseline = sensorReading;

  //reset counters
  baselineBufferIndex = 0;
  sustainCount = 0;
}


void FSR::baselineReset() {
  jumpThreshold = updateThreshold(baselineBuffer, baseline, jumpThreshold);
  int maxBaseline = MAX_READING - jumpThreshold - MIN_JUMPING_RANGE;
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
      Serial.println("WARNING: Exceeded ULONG_MAX while running varianceFromTarget(). Check your parameters to ensure buffers aren't too large.");
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
      Serial.println("WARNING: Exceeded ULONG_MAX while running bufferAverage(). Check your parameters to ensure buffers aren't too large.");
      delay(1000);
      break;
    }
  }
  return (int) (sum / i);
}

void fsrGridSetup(FSR** FSR_GRID, const int* sensor_pins, const int* notes) {
  for (int i = 0; i < NUM_FSR_SENSORS; i++) {
    FSR_GRID[i] = new FSR(sensor_pins[i], notes[i], i);
    FSR_GRID[i]->calibrate();
  }
}

void fsrGridRead(FSR** FSR_GRID){
    for (int i = 0; i < NUM_FSR_SENSORS; i++) {
    FSR_GRID[i]->readResistance();
  }
}

void fsrGridRead(FSR** FSR_GRID, int sensor){
    FSR_GRID[sensor]->readResistance();
}

void fsrGridPrintReadActive(FSR** FSR_GRID){
  for (int i = 0; i < NUM_FSR_SENSORS; i++) {
    FSR_GRID[i]->printReadActive();
  }
}

void fsrGridPrintReadActive(FSR** FSR_GRID, int sensor){
    FSR_GRID[sensor]->printReadActive();
}
