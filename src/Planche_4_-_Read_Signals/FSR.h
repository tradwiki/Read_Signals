#include "config.h"
#include "Arduino.h"

class FSR {

  private:

    int PIN;
    int NOTE;
    int INDEX;
    boolean midiOn;
    boolean oscOn;


    bool IS_CLOCKING_PAD;
    static const int BASELINE_BUFFER_SIZE = 1000;

    //MAX READING DEPENDING ON VOLTAGE
    const int MAX_READING = 1023;
    const int MIN_THRESHOLD = 150;
    const int MAX_THRESHOLD = 150;
    const int MIN_JUMPING_RANGE = 80;

    unsigned const long NOTE_VELOCITY_DELAY = 2 * MILLISECOND;
    unsigned const long NOTE_ON_DELAY = 50 * MILLISECOND;
    unsigned const long NOTE_OFF_DELAY = 50 * MILLISECOND;
    unsigned const long SUSTAIN_DELAY = 100 * MILLISECOND;
    unsigned const long BASELINE_SAMPLE_DELAY = 0.5 * MILLISECOND;
    unsigned const long BASELINE_BLOWBACK_DELAY = 40 * MILLISECOND;

    const int RETRO_JUMP_BLOWBACK_SAMPLES = (0.5 * MILLISECOND) / BASELINE_SAMPLE_DELAY;
    const int MAX_CONSECUTIVE_SUSTAINS = (10 * SECOND) / SUSTAIN_DELAY;

    int baseline;
    int jumpThreshold;
    int tapsToIgnore;
    unsigned long lastExternalMidiOn;
    String state;
    int sensorReading;
    int distanceAboveBaseline;
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
    
    void calibrate();
    void read();

    //setters and getters
    int getPin();
    int getNote();
    void setPin(int n);
    void setNote(int n);
    
    int bufferAverage(int * a, int aSize);
    int varianceFromTarget(int * a, int aSize, int targer);
    void updateRemainingTime(unsigned long (&left), unsigned long (&last));
    int updateThreshold(int (&baselineBuff)[1000], int oldBaseline, int oldThreshold);

    void jumping();
    void rising();
    void falling();
    void sustained();
    void baselining();
    void externalMidiSustains(bool isLocal);

    void readExternalMIDI();

    void sendMidi();
    void sendOsc();

    void printReading();
};
