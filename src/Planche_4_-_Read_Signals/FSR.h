#pragma once
#include "config.h"
#include "Arduino.h"

class FSR {

  private:

    int PIN;
    int NOTE;
    int INDEX;
    boolean WITH_MIDI;

    bool IS_CLOCKING_PAD;

    int baseline;
    int jumpThreshold;
    int tapsToIgnore;
    String state;
    int sensorReading;
    int distanceAboveBaseline;
    int velocity;
    bool justJumped;
    int baselineBuffer[BASELINE_BUFFER_SIZE];
    int baselineBufferIndex;
    int sustainCount;
    unsigned long toWaitBeforeBaseline;
    unsigned long toWaitBeforeRising;
    unsigned long toWaitBeforeFalling;
    unsigned long toWaitBeforeSustaining;
    unsigned long lastRisingTime;
    unsigned long lastSustainingTime;
    unsigned long lastBaselineTime;
    unsigned long duration;

  public:
    FSR();
    FSR(const int pin, const int note, const int index);
    FSR& operator=(const FSR&);

    int getPin();
    int getNote();
    String getState();
    int getSensorReading();
    int getScaledVelocity();

    void calibrate();
    void readResistance();
    void jumping();
    void rising();
    void falling();
    void sustained();
    void baselining();
    void baselineReset();
    void sustainReset();
    void sample();

    void updateSustainCount();
    int updateThreshold(int (&baselineBuff)[BASELINE_BUFFER_SIZE], int oldBaseline, int oldThreshold);
    void updateRemainingTime(unsigned long (&left), unsigned long (&last));
    int varianceFromTarget(int * a, int aSize, int target);
    int bufferAverage(int * a, int aSize);
    void checkSustainCount();

    void sendMidiSignal();
    void sendMotorSignal();

    void printRead();
    void printReadActive();
};

void fsrSetup(FSR** FSR_GRID, const int* sensor_pins, const int* notes);
void fsrRead(FSR** FSR_GRID);
void fsrRead(FSR** FSR_GRID, int sensor);
void fsrPrintReadActive(FSR** FSR_GRID);
void fsrPrintReadActive(FSR** FSR_GRID, int sensor);
void sendFSRMidi(FSR** FSR_GRID, int sensor);
void sendFSRMidi(FSR** FSR_GRID);
