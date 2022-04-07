//#include "Piezo_Grid.h" 
//
//Piezo_Grid::Piezo_Grid(){
//  
//}
//
//Piezo_Grid::Piezo_Grid(const int* sensor_pins, const int* notes) {
//  for (int i = 0; i < NUM_PIEZO_SENSORS; i++){
//    sensors[i] = new Piezo(sensor_pins[i], notes[i], i);
//  } 
//}
//
//Piezo_Grid& Piezo_Grid::operator=(const Piezo_Grid&)
//{
//  return *this;
//}
//
//void Piezo_Grid::readResistance(){
//  for (int currSensor = 0; currSensor < _NUM_PIEZO_SENSORS; currSensor++){
//    piezo[currSensor]->readResistance();
//  }
//}
//
//void Piezo_Grid::readResistance(int currSensor){
//  piezo[currSensor]->readResistance();
//}
//
//void Piezo_Grid::sendMidiSignal(){
//  for (int currSensor = 0;i < NUM_PIEZO_SENSORS; currSensor++){
//    piezo[currSensor]->sendMidiSignal();
//  }
//}
//
//void Piezo_Grid::sendMidiSignal(int currSensor){
//  piezo(currSensor)->readResistance();
//}
//}
