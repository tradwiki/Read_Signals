//String MODE = "Spirale";
Mode currMode;
Planche planche;

ScrollRect scrollRect;
float heightOfCanvas = 600;

int screenWidth = 710;
int screenHeight = 400;

void setup() {
  size(730, 1700);
  //noCursor();
  currMode = new Raindrop();
  scrollRect = new ScrollRect();
  planche = new Planche();
}

void draw() {
  currMode.bg();
  scrollRect.display();
  scrollRect.update();
  
  pushMatrix();
  float newYValue = -scrollRect.scrollValue();
  translate (0, newYValue);
  currMode.drawScreens();

  currMode.display();
  currMode.update();
  popMatrix();
}


class Mode {
  color BG_COLOR;

  Mode() {
  }
  void display() {
  }
  void update() {
  }
  void handleOSC() {
  }
  void bg() {
  }
  
  void drawScreens() {
    stroke(255);
    strokeWeight(2);
    noFill();
    rect(0, 0, screenWidth, screenHeight);
    stroke(255, 0, 0);
    rect(0, 400, screenWidth, screenHeight);
    stroke(0, 255, 0);
    rect(0, 800, screenWidth, screenHeight);
  }
}

void mousePressed() {
  scrollRect.mousePressedRect();
}

void mouseReleased() {
  scrollRect.mouseReleasedRect();
}
