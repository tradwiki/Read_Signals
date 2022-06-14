import themidibus.*; //Import the library
import javax.sound.midi.MidiMessage; //Import the MidiMessage classes http://java.sun.com/j2se/1.5.0/docs/api/javax/sound/midi/MidiMessage.html
import javax.sound.midi.SysexMessage;
import javax.sound.midi.ShortMessage;

MidiBus myBus; // The MidiBus
Planche planche;

int[] GRID_POS = {175, 205};
int[] BAR_POS = {375, 55};
int[] GRAPH_POS = {700, 75};
int[] INTERPRET_POS = {500, 600};

void setup() {
  size(1080, 800);
  background(0);

  MidiBus.list(); // List all available Midi devices on STDOUT. This will show each device's index and name.
  myBus = new MidiBus(this, 1, 0); // Create a new MidiBus object

  planche = new Planche();
}

void draw() {
  //background(0);
  planche.showGrid(GRID_POS[0], GRID_POS[1]);
  planche.showBar(BAR_POS[0], BAR_POS[1]);
  planche.showGraph(GRAPH_POS[0], GRAPH_POS[1]);
  planche.showInterpret(INTERPRET_POS[0], INTERPRET_POS[1]);
}


void midiMessage(MidiMessage message) { // You can also use midiMessage(MidiMessage message, long timestamp, String bus_name)
  // Receive a MidiMessage
  // MidiMessage is an abstract class, the actual passed object will be either javax.sound.midi.MetaMessage, javax.sound.midi.ShortMessage, javax.sound.midi.SysexMessage.
  // Check it out here http://java.sun.com/j2se/1.5.0/docs/api/javax/sound/midi/package-summary.html
  println();
  println("MidiMessage Data:");
  println("--------");
  println("Status Byte/MIDI Command:"+message.getStatus());
  for (int i = 1;i < message.getMessage().length;i++) {
    println("Param "+(i+1)+": "+(int)(message.getMessage()[i] & 0xFF));
  }
  if (message.getMessage().length > 1){
  planche.handleNote(message.getMessage()[1], message.getMessage()[2]);
  }
}

void delay(int time) {
  int current = millis();
  while (millis () < current+time) Thread.yield();
}

void keyPressed(){
  if (key == ' '){
    planche.pauseGraph = !planche.pauseGraph;
    planche.pauseBar = !planche.pauseBar;
    printArray(PFont.list());
  }
  
  if (key == 'r'){
    planche.restartGraph(width - 400, height * 1 /8 - 50);
  }
  
  if (key == 'g'){
    planche.pauseGraph = !planche.pauseGraph;
  }
  
  if (key == 'b'){
    planche.pauseBar = !planche.pauseBar;
  }
  
}
