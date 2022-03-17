FSR::FSR() {

}

FSR::FSR(const int pin, const int note, const int index) : PIN(pin), NOTE(note), INDEX(index) {

  midiOn = false;
  oscOn = false;

  IS_CLOCKING_PAD = false;
  baseline = 0;
  jumpThreshold = 0;
  tapsToIgnore = 0;
  lastExternalMidiOn = 0;
  state = "IDLE";
};

FSR& FSR::operator=(const FSR&)
{
  return *this;
}

int FSR::getPin() {
  return PIN;
}

int FSR::getNote() {
  return NOTE;
}

void FSR::setPin(int n) {
  this->PIN = n;
}

void FSR::setNote(int n) {
  this->NOTE = n;
}

void FSR::calibrate() {
  baseline = analogRead(PIN);
  jumpThreshold = (MIN_THRESHOLD + MAX_THRESHOLD) / 2;
}


int FSR_GRID::bufferAverage(int *a, int aSize) {
  unsigned long sum = 0;
  int i = 0;
  for (i = 0; i < aSize; i++) {

    if (sum < (ULONG_MAX - a[i])) {
      sum += a[i];
    }

    else {
      Serial.println("WARNING: Exceeded ULONG_MAX while running bufferAverage(). Check your parameters to ensure buffers aren't too large.");
      delay(1000);
      break;
    }
  }
  return (int) (sum  / i);
}

int FSR::varianceFromTarget(int *a, int aSize, int target) {
  unsigned long sum =  0;
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

int FSR::updateThreshold(int (&baselineBuff)[1000], int oldBaseline, int oldThreshold) {

  int varianceFromBaseline = varianceFromTarget(baselineBuff, BASELINE_BUFFER_SIZE, oldBaseline);
  int newThreshold = constrain(varianceFromBaseline, MIN_THRESHOLD, MAX_THRESHOLD);

  int deltaThreshold = newThreshold - oldThreshold;
  if (deltaThreshold < 0) {
    //split the difference to slow down threshold becoming more sensitive
    newThreshold = constrain(oldThreshold + ((deltaThreshold) / 4), MIN_THRESHOLD, MAX_THRESHOLD);
  }

  return newThreshold;
}

void FSR::rising(int velocity) {

  if (midiOn) {
    int maxVelocity = MAX_READING - baseline;
    int constrainedVelocity = constrain(velocity, jumpThreshold, maxVelocity);
    scaledVelocity =  map(constrainedVelocity, jumpThreshold, maxVelocity, 64, 127);

    //    usbMIDI.sendNoteOn(NOTES[sensor], scaledVelocity, MIDI_CHANNEL);
    state = "RISING";
    if (DEBUG) {
      Serial.print("RISING: ");
      Serial.print(NOTE);
      Serial.print(" ");
      Serial.print(scaledVelocity);
    }

    if (IS_CLOCKING_PAD) {
      //      usbMIDI.sendRealTime(usbMIDI.Clock);
      //      usbMIDI.send_now();
      delay(10);

    }
  }

  lastRisingTime = micros();
  toWaitBeforeFalling = NOTE_ON_DELAY;

  lastSustainingTime = micros();
  toWaitBeforeSustaining = SUSTAIN_DELAY;

  justJumped = true;
  sustainCount++;
}

void FSR::falling() {

  if (DEBUG) {
    Serial.print("FALLING: ");
    Serial.print(PIN);
    Serial.print(" ");
    Serial.print(NOTE);
    Serial.println();
  }

  state = "FALLING";
  delay(10);
}

void FSR::baselining() {
  if (baselineBufferIndex > (BASELINE_BUFFER_SIZE - 1)) {
    jumpThreshold = updateThreshold(baselineBuffer, baseline, jumpThreshold);
    int maxBaseline = MAX_READING - jumpThreshold - MIN_JUMPING_RANGE;
    baseline = min(bufferAverage(baselineBuffer, BASELINE_BUFFER_SIZE), maxBaseline);
    //reset counter
    baselineBufferIndex = 0;
  }
  //WAIT
  else if (toWaitBeforeBaseline > 0) {
    updateRemainingTime(toWaitBeforeBaseline, lastBaselineTime);
  }
  //SAMPLE
  else {
    baselineBuffer[baselineBufferIndex] = sensorReading;
    baselineBufferIndex++;

    //reset timer
    lastBaselineTime = micros();
    toWaitBeforeBaseline = BASELINE_SAMPLE_DELAY;
  }
}

void FSR::jumping() {
  if (toWaitBeforeRising > 0) {
    updateRemainingTime(toWaitBeforeRising, lastRisingTime);
  }
  //TRIGGER DELAY
  else {
    lastRisingTime = micros();
    toWaitBeforeRising = NOTE_VELOCITY_DELAY;
    sustainCount++;
  }

  lastRisingTime = micros();
  toWaitBeforeFalling = NOTE_ON_DELAY;

  lastSustainingTime = micros();
  toWaitBeforeSustaining = SUSTAIN_DELAY;

  justJumped = true;
  sustainCount++;
}

void FSR::read() {
  sensorReading = analogRead(PIN);
  distanceAboveBaseline = max(0, sensorReading - baseline);

  //JUMPING
  if (distanceAboveBaseline >= jumpThreshold) {
    //VELOCITY OFFSET
    state = "JUMPING";
    if (sustainCount == 0) {
      state = "JUMPING";
      jumping();
    }
    //RISING
    else if (sustainCount == 1) {
      //WAIT
      //waiting is caused by velocity the velocity offset delay
      if (toWaitBeforeRising > 0) {
        updateRemainingTime(toWaitBeforeRising, lastRisingTime);
      }
      //SIGNAL
      else {
        state = "RISING";
        velocity = distanceAboveBaseline;
        rising();
      }
    }
    //SUSTAINING
    else {
      //RESET
      if (sustainCount > MAX_CONSECUTIVE_SUSTAINS) {
        baseline = sensorReading;

        //reset counters
        baselineBufferIndex = 0;
        sustainCount = 0;
      }
      //WAIT
      else if (toWaitBeforeSustaining > 0) {
        updateRemainingTime(toWaitBeforeSustaining, lastSustainingTime);
      }
      //SIGNAL
      else {
        state = "SUSTAINED";
        velocity = distanceAboveBaseline;
        duration = NOTE_VELOCITY_DELAY + ((sustainCount - 1) * SUSTAIN_DELAY);
        sustained(true);

        lastSustainingTime = micros();
        toWaitBeforeSustaining = SUSTAIN_DELAY;
        sustainCount++;
      }
    }
  }
  //NOT JUMPING
  else {
    //FALLING
    if (justJumped) {
      //WAIT
      if (toWaitBeforeFalling) {
        updateRemainingTime(toWaitBeforeFalling, lastRisingTime);
      }
      //SIGNAL
      else {
        state = "FALLING";

        //wait before sending more midi signals
        //debounces falling edge
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
    }
    //BASELINING
    else {
      //reset jump counter
      state = "BASELINING";
      sustainCount = 0;

      //RESET
      baselining();
    }
  }
}


void FSR::printReading() {
  Serial.print("FSR ");
  Serial.print(INDEX);
  Serial.print(" : ");
  Serial.println(sensorReading);
}
