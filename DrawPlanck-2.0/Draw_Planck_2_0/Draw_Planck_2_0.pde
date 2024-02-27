//String MODE = "Spirale"; //<>//
import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myBroadcastLocation; 

Mode currMode;
Mode rd;
Planche planche;

ScrollRect scrollRect;
float heightOfCanvas = 600;

int screenWidth = 710;
int screenHeight = 400;

boolean changeMode;
String nextMode;

int returnCount;

void setup() {
  size(730, 900);
  //noCursor();
  currMode = new Menu();
  scrollRect = new ScrollRect();
  planche = new Planche();

  oscP5 = new OscP5(this, 5005);

  changeMode = false;
  nextMode = "";

  returnCount = 0;
}

void draw() {
  currMode.bg();
  scrollRect.display();
  scrollRect.update();

  pushMatrix();
  float newYValue = -scrollRect.scrollValue();
  translate (0, newYValue);
  planche.update();

  //planche
  if (! currMode.doOutro) {
    currMode.display();
    currMode.update();
    currMode.drawScreens();
  } else {
    currMode.outro();
  }
  popMatrix();

  checkMode();
}


class Mode {
  String name;
  color BG_COLOR;
  int outroCount = 0;
  boolean doOutro = false;
  Mode() {
    name = "";
  }

  String getName() {
    return this.name;
  }

  void display() {
  }
  void update() {
  }
  void handleOSC(OscMessage theOscMessage) {
  }
  void bg() {
  }

  void oscEvent() {
  }

  void drawScreens() {
    stroke(255);
    strokeWeight(2);
    noFill();
    rectMode(CORNER);
    rect(0, 0, screenWidth, screenHeight);
    stroke(255, 0, 0);
    rect(0, 400, screenWidth, screenHeight);
    stroke(0, 255, 0);
    rect(0, 800, screenWidth, screenHeight);
  }

  void outro() {
    if (outroCount < 255) {
      outroCount += 2;
      fill(0, 0, 0, outroCount);
      rect(0, 0, screenWidth, screenHeight * 3);
      textAlign(CENTER);
      textSize(36);
      fill(255);
      text(nextMode, screenWidth / 2, screenHeight * 1.5);
    } else {
      changeMode = true;
      doOutro = false;
    }
  }
}

void checkMode() {
  if (changeMode) {
    if (nextMode.equals("Menu")) {
      currMode = new Menu();
      returnCount = 0;
    }
    if (nextMode.equals("Raindrop")) {
      currMode = new Raindrop();
    }
    if (nextMode.equals("Moniteur")) {
      currMode = new Monitor();
    }

    if (nextMode.equals("Mondrian")) {
      currMode = new Mondrian();
    }
    
    if (nextMode.equals("Reboisons")) {
      currMode = new Reboisons();
    }
    
    changeMode = false;
    nextMode = "";
  }

  if (returnCount > 500 && !(currMode.getName().equals("Menu"))) {
    nextMode = "Menu";
    currMode.doOutro = true;
  }
}

void mousePressed() {
  scrollRect.mousePressedRect();
}

void mouseReleased() {
  scrollRect.mouseReleasedRect();
}

void oscEvent(OscMessage theOscMessage) {
  if (theOscMessage.checkAddrPattern("/FSR/PG") && !currMode.getName().equals("Menu")) {
    returnCount++;
  } 
  if ((theOscMessage.checkAddrPattern("/FSR/PD")) || (theOscMessage.checkAddrPattern("/FSR/AG")) || (theOscMessage.checkAddrPattern("/FSR/AD"))){
    returnCount = 0;
  }
  currMode.handleOSC(theOscMessage);
  planche.handleOSC(theOscMessage);
}

void keyPressed() {
  print(returnCount);
}
