#include "FSR_GRID.h" 

FSR_GRID::FSR_GRID(){
  
}

FSR_GRID::FSR_GRID(const int* sensor_pins, const int* notes) {
  for (int i = 0; i < NUM_FSR_SENSORS; i++){
    sensors[i] = new FSR(sensor_pins[i], notes[i], i);
  } 
}

FSR_GRID& FSR_GRID::operator=(const FSR_GRID&)
{
  return *this;
}

void FSR_GRID::calibrateOne(int currSensor){
  sensors[currSensor]->calibrate();
}

void FSR_GRID::calibrateAll(){
    for (int sensor = 0; sensor < NUM_FSR_SENSORS; sensor++) {
      calibrateOne(sensor);
  }
}

void FSR_GRID::readResistance(int currSensor){
  sensors[currSensor]->readResistance();
}

void FSR_GRID::readResistance(){
  for (int currSensor = 0; currSensor < NUM_FSR_SENSORS; currSensor++){
    sensors[currSensor]->readResistance();
  }
}

void FSR_GRID::printRead(int currSensor){
  sensors[currSensor]->printRead();
}

void FSR_GRID::printReadActive(int currSensor){
  sensors[currSensor]->printReadActive();
}

void FSR_GRID::printRead(){
  for (int currSensor = 0; currSensor < NUM_FSR_SENSORS; currSensor++){
    sensors[currSensor]->printRead();
  }
}

void FSR_GRID::printReadActive(){
  for (int currSensor = 0; currSensor < NUM_FSR_SENSORS; currSensor++){
    sensors[currSensor]->printReadActive();
  }
}

void FSR_GRID::sendMidiSignal(){
  for (int sensor = 0; sensor < NUM_FSR_SENSORS; sensor++){
    sensors[sensor]->sendMidiSignal();
  }
}
//int FSR_GRID::sensorToMotor(int sensorIndex) {
//  if (SENSOR_TO_MOTOR[sensorIndex] == -1) {
//    //Turn on LED instead of motor
//    return LED_PIN;
//  }
//  else {
//    return MOTOR_PINS[SENSOR_TO_MOTOR[sensorIndex]];
//  }
//}

//int FSR_GRID::noteToSensor(int note) {
//  for (int i = 0; i < NUM_FSR_SENSORS; i++) {
//    if (sensors[i].getNote() == note) {
//      return i;
//    }
//  }
//  return -1;
//}
