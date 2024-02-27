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
    int scaledVelocity;
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
    int getVelocity();
    int getScaledVelocity();
    int getBaseline();
    bool isActive();

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

class Pad {
  FSR* sensors[2];
  int NOTE;
  int INDEX;
  String state;
//  int read[2];

  
  public:
    Pad();
    Pad(const int note, const int index, FSR* fsr0, FSR* fsr1);
    Pad& operator=(const Pad&);

    int getNote();
    String getState();
    int getReading();
    int getReading(int n);
    bool isActive();

    void sendMidiSignal();
    void getRead();
};

void fsrSetup(FSR** FSR_GRID, const int* sensor_pins, const int* notes);
void fsrRead(FSR** FSR_GRID);
void fsrRead(FSR** FSR_GRID, int sensor);
void padRead(Pad** PAD_GRID);
void padSetup(Pad** PAD_GRID, FSR** FSR_GRID, const int* notes);
void padSendMidi(Pad** FSR_GRID);
void padPrintRead(FSR** FSR_GRID);
void fsrPrintReadActive(FSR** FSR_GRID);
void fsrPrintReadActive(FSR** FSR_GRID, int sensor);
void sendFSRMidi(FSR** FSR_GRID, int sensor);
void sendFSRMidi(FSR** FSR_GRID);
