#include "config.h"
#include "FSR.h"

class FSR_GRID {
  private:

  FSR sensors[NUM_FSR_SENSORS];
  
  public:

  FSR_GRID(const int* sensor_pins, const int* notes);

  void calibrateOne(int currSensor);
  void calibrateAll();
  
  void readAll();
  void readOne(int currentSensor);
  
  int bufferAverage(int * a, int aSize);
  int varianceFromTarget(int * a, int aSize, int targer);
  void updateRemainingTime(unsigned long (&left), unsigned long (&last));
  int updateThreshold(int (&baselineBuff)[1000], int oldBaseline, int oldThreshold);

  int sensorToMotor(int sensorIndex);
  int noteToSensor(int note);

  void readExternalMIDI();

  void printReading(int currentSensor);
  void printAllReadings();
  void printAllTriggered();

  void setMidiOn(bool setting);
  void setOscOn(bool setting);  
};
