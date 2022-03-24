#include <limits.h>
#include "config.h"
//#include "FSR_GRID.h"
#include "FSR.H"

//FSR_GRID fsr_grid;

FSR fsr1 = FSR(25, 1, 1);
void setup() {
  fsr1.calibrate();
  Serial.println("HI, this is a test");
  Serial.println(fsr1.getPin());
}

void loop() {
  fsr1.readResistance();
  delay(10);
}
