import themidibus.*; //Import the library
import javax.sound.midi.MidiMessage; //Import the MidiMessage classes http://java.sun.com/j2se/1.5.0/docs/api/javax/sound/midi/MidiMessage.html
import javax.sound.midi.SysexMessage;
import javax.sound.midi.ShortMessage;
import oscP5.*;
import netP5.*;


int myBroadcastPort = 18032;
NetAddress myRemoteLocation = new NetAddress("127.0.0.1", 18032);
String myConnectPattern = "/server/connect";
String myDisconnectPattern = "/server/disconnect";
OscP5 oscP5;

float heightOfCanvas = 2200;
//TODO
// ADJUST THE FUNCTIONS To CHANGE GRID DIMENSIONS
MidiBus myBus; // The MidiBus
Planche planche;
ScrollRect scrollRect;

int[] GRID_POS = {240, 200};
int[] BAR_POS = {55, 500};
int[] GRAPH_POS = {55, 700};
int[] INTERPRET_POS = {200, 1500};
int GRAPH_WIDTH = 1100;
int GRAPH_HEIGHT = 50;

//color BG_COLOR = color(108, 150, 184);
color BG_COLOR = color(100, 0, 200);

//int GRAPH_WIDTH = 1150;
//int GRAPH_HEIGHT = 60;

void setup() {
  size(1280, 1300);
  print(width);
  print(height);
  //fullScreen();
  print(width);
  print(height);
  background(0);

  MidiBus.list(); // List all available Midi devices on STDOUT. This will show each device's index and name.
  myBus = new MidiBus(this, 1, -1); // Create a new MidiBus object

  planche = new Planche();
  scrollRect = new ScrollRect();

  oscP5 = new OscP5(this, 12000);
  background(BG_COLOR);
  frameRate(30);
}

void draw() {
  noCursor();
  background(BG_COLOR);
  scrollRect.display();
  scrollRect.update();
  pushMatrix();

  // reading scroll bar
  float newYValue = scrollRect.scrollValue();
  translate (0, newYValue);
  //background(0);
  planche.showGrid(GRID_POS[0], GRID_POS[1]);
  //planche.showBarVertical(BAR_POS[0], BAR_POS[1]);
  //planche.showGraph(GRAPH_POS[0], GRAPH_POS[1], GRAPH_WIDTH, GRAPH_HEIGHT);
  planche.mur2(0, 400);
  //planche.showGraph(80, 50, GRAPH_WIDTH, GRAPH_HEIGHT);
  stroke(0, 255, 0);
  noFill();
  strokeWeight(2);
  //rect(0, 0, 480, 400);
  //rect(0, 400, 800, 400);
  //rect(0, 800, 800, 400);
  //planche.showInterpret(INTERPRET_POS[0], INTERPRET_POS[1]);

  popMatrix();
}


void midiMessage(MidiMessage message) { // You can also use midiMessage(MidiMessage message, long timestamp, String bus_name)
  // Receive a MidiMessage
  // MidiMessage is an abstract class, the actual passed object will be either javax.sound.midi.MetaMessage, javax.sound.midi.ShortMessage, javax.sound.midi.SysexMessage.
  // Check it out here http://java.sun.com/j2se/1.5.0/docs/api/javax/sound/midi/package-summary.html
  println();
  println("MidiMessage Data:");
  println("--------");
  println("Status Byte/MIDI Command:"+message.getStatus());
  for (int i = 1; i < message.getMessage().length; i++) {
    println("Param "+(i+1)+": "+(int)(message.getMessage()[i] & 0xFF));
  }
  if (message.getMessage().length > 1) {
    planche.handleNote(message.getMessage()[1], message.getMessage()[2]);
    sendOsc(message.getMessage()[1]);
  }
}

void delay(int time) {
  int current = millis();
  while (millis () < current+time) Thread.yield();
}

void keyPressed() {
  if (key == ' ') {
    planche.pauseGraph = !planche.pauseGraph;
    planche.pauseBar = !planche.pauseBar;
    printArray(PFont.list());
  }

  if (key == 'r') {
    //planche.restartGraph(width - 400, height * 1 /8 - 50, GRAPH_WIDTH, GRAPH_HEIGHT);
    planche.restartGraph(width / 2, height / 2, GRAPH_WIDTH, GRAPH_HEIGHT);
  }

  if (key == 'g') {
    planche.pauseGraph = !planche.pauseGraph;
  }

  if (key == 'b') {
    planche.pauseBar = !planche.pauseBar;
  }
}

void mousePressed() {
  scrollRect.mousePressedRect();
}

void mouseReleased() {
  scrollRect.mouseReleasedRect();
}

void sendOsc(int note) {
  OscMessage myMessage = new OscMessage("/satie/source/set");
  myMessage.add("micro");
  myMessage.add("aziDeg");
  switch (note) {

  case 74:
    myMessage.add(float(45));
    oscP5.send(myMessage, myRemoteLocation);
    break;
  case 76:
    myMessage.add(float(45));
    oscP5.send(myMessage, myRemoteLocation);
    break;
    
  case 78:
    myMessage.add(float(135));
    oscP5.send(myMessage, myRemoteLocation);
    break;

  case 79:
    myMessage.add(float(135));
    oscP5.send(myMessage, myRemoteLocation);
    break;

  case 81:
    myMessage.add(float(-45));
    oscP5.send(myMessage, myRemoteLocation);
    break;

  case 83:
    myMessage.add(float(-45));
    oscP5.send(myMessage, myRemoteLocation);
    break;
    

  case 85:
    myMessage.add(float(-135));
    oscP5.send(myMessage, myRemoteLocation);
    break;


  case 86:
    myMessage.add(float(-135));
    oscP5.send(myMessage, myRemoteLocation);
    break;

  }
}
