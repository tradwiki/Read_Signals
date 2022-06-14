int NUM_FSR = 8; //<>// //<>//
int NUM_PIEZO = 4;

int FSR_STATE_THRESHOLD = 10;
int PIEZO_STATE_THRESHOLD = 10;
int PLEIN_PIED_THRESHOLD = 10;
int PLEIN_PIED_MEAN = 50;
int FSR_MAX_TIME = 3000;
int PIEZO_MAX_TIME = 3000;

int[] FSR_NOTES = {74, 76, 79, 78, 81, 83, 85, 86};
int[] PIEZO_NOTES = {1, 2, 3, 4};

int FSR_GRAPH_WIDTH = 350;
int MAX_BAR_TIME = 3000;

class Sensor {
  int id, note;
  String type;
  boolean state; 
  int read, max;
  PFont font;
  int timer;
  int stateThreshold, maxTime;

  Sensor(String type, int id, int note) {
    this.type = type;
    this.id = id;
    this.note = note;
    this.read = 0;
    this.state = false;
    this.font = createFont("Menlo-regular", 14);

    if (type == "fsr") {
      this.stateThreshold = FSR_STATE_THRESHOLD;
      this.maxTime = FSR_MAX_TIME;
    } else {
      this.stateThreshold = PIEZO_STATE_THRESHOLD;
      this.maxTime = PIEZO_MAX_TIME;
    }
  }

  int getRead() {
    return this.read;
  }

  void setRead(int r) {
    this.read = r;
    state = false;

    if (read > stateThreshold) {
      state = true;
    }
    if (read > max || (millis() - timer) > maxTime) {
      this.max = read;
      this.timer = millis();
    }
  }

  void showGraph(int x, int y, float graphX) {
    noStroke();
    textFont(font);
    fill(255);
    text(type + id, x, y - 5);
    noFill();
    strokeWeight(2);
    stroke(255);
    rectMode(CORNER);
    rect(x, y, FSR_GRAPH_WIDTH, 30);
    float graphY = map(read, 0, 127, 0, 25);
    fill(255);
    noStroke();
    rect(x+graphX, y + 25 - graphY, 1, 1);
  }

  void showBar(int x, int y) {
    rectMode(CORNER);
    fill(0, 255, 0);
    rect(x, y - read + 127, 20, read);
    stroke(255);
    strokeWeight(1);
    noFill();
    rect(x, y, 20, 127);
    if (millis() - this.timer < maxTime && max > 0) {
      fill(255, 0, 0);
      rect(x, y - max + 127, 20, 2);
    }
    String letter = "f";
    if (type == "piezo") {
      letter = "p";
    }

    noStroke();
    textFont(font);
    fill(255);
    text(letter + id, x - 5, y + 150);
  }
}

class Planche {
  Sensor[] fsr;
  Sensor[] piezo;
  Sensor[] sGauche, sDroite;
  float graphX;
  boolean pauseGraph, pauseBar; 
  float mean;
  PFont font;

  Planche() {
    this.font = createFont("Menlo-regular", 14);
    this.pauseGraph = false;
    this.pauseBar = false;
    this.fsr = new Sensor[NUM_FSR];
    this.piezo = new Sensor[NUM_PIEZO];
    this.sGauche = new Sensor[6];
    this.sDroite = new Sensor[6];
    this.mean = 0;

    for (int i = 0; i < NUM_FSR; i++) {
      fsr[i] = new Sensor("fsr", i, FSR_NOTES[i]);
    }

    for (int i = 0; i < NUM_PIEZO; i++) {
      piezo[i] = new Sensor("piezo", i, PIEZO_NOTES[i]);
    }

    for (int i = 0; i < 4; i++) {
      sGauche[i] = fsr[i];
      sDroite[i] = fsr[i + 4];
    }

    for (int i = 0; i < 2; i ++) {
      sGauche[i + 4] = piezo[i];
      sDroite[i + 4] = piezo[i + 2];
    }
  }

  void showGrid(int x, int y) {
    fill(255);
    textFont(font);
    textAlign(LEFT);
    text("Senseurs actifs", x - 150, y - 160);
    rectMode(CENTER);
    fill(0);
    noStroke();
    rect(x, y, 300, 300);
    strokeWeight(2);
    stroke(255);
    noFill();
    rect(x - 75, y - 75, 150, 150);
    rect(x + 75, y - 75, 150, 150);
    rect(x - 75, y + 75, 150, 150);
    rect(x + 75, y + 75, 150, 150);

    for (int i = 0; i < fsr.length; i++) {

      float tempX = x - 185 + 70 * (i % 4 + 1);
      float tempY = y - 110;

      if ((i > 1 && i < 4) || (i > 5)) {
        tempX += 20;
      }

      if (i >= 4) {
        tempY = y + 110;
      }

      noStroke();
      fill(255);
      rect(tempX, tempY, 50, 50);
      fill(255, 255 - map(fsr[i].read, 0, 127, 0, 255), 0);
      rect(tempX, tempY, map(fsr[i].read, 0, 127, 0, 50), map(fsr[i].read, 0, 127, 0, 45));
    }

    for (int i = 0; i < piezo.length; i++) {
      float tempX = x - 80 + 160 * (i % 2);

      float tempY = y  - 50;

      if (i >= 2) {
        tempY = y + 50;
      }
      fill(255);
      ellipse(tempX, tempY, 50, 50);
      fill(255, 255 - map(piezo[i].read, 0, 127, 0, 255), 0);
      ellipse(tempX, tempY, map(piezo[i].read, 0, 127, 0, 50), map(piezo[i].read, 0, 127, 0, 50));
    }
  }

  void restartGraph(int x, int y) {
    fill(0);
    rectMode(CORNER);
    graphX = 0;
    rect(x, y, FSR_GRAPH_WIDTH, 75 * NUM_FSR + 100);
  }

  boolean piedPlein(Sensor[] cote) {
    this.mean = 0;
    for (int i = 0; i < 6; i++) {
      this.mean = cote[i].getRead();
    }
    mean = mean / 6;
    boolean c1 = cote[4].read > PLEIN_PIED_THRESHOLD;
    boolean c2 = cote[5].read > PLEIN_PIED_THRESHOLD;
    boolean c3 = mean > PLEIN_PIED_MEAN;
    return c1 && c2 && c2;
  }

  void showGraph(int x, int y) {
    fill(255);
    textAlign(LEFT);
    text("Signal dans le temps", x, y - 30);
    if (!pauseGraph) {
      graphX++;

      if (graphX > FSR_GRAPH_WIDTH) {
        restartGraph(x, y);
      }

      for (int i = 0; i < NUM_FSR; i++) {
        fsr[i].showGraph(x, y + i * 50, graphX);
      }
    } else {
      if (mouseX > x - 30 && mousePressed) {
        strokeWeight(1);
        stroke(255, 0, 0);
        line(x, mouseY, width - 10, mouseY);
        line(mouseX, y - 10, mouseX, height - 10);
      }
    }
  }

  void handleNote(int note, int velocity) {

    for (int i = 0; i < NUM_FSR; i++) {
      if (note == fsr[i].note) {
        fsr[i].setRead(velocity);
      }
    }

    for (int i = 0; i < NUM_PIEZO; i++) {
      if (note == piezo[i].note) {
        piezo[i].setRead(velocity);
      }
    }
  }

  void showBar(int x, int y) {
    fill(255);
    textAlign(LEFT);
    text("Niveaux senseurs", x, y - 10);
    if (!pauseBar) {
      int tempX, tempY;
      fill(0);
      rectMode(CORNER);
      rect(x - 5, y - 5, 270, 330);
      for (int i = 0; i < NUM_FSR; i++) {
        tempY = y;
        tempX = x + i % 4 * 80;

        if (i > 3) {
          tempY = y + 173;
        }

        fsr[i].showBar(tempX, tempY);
      }

      for (int i = 0; i < NUM_PIEZO; i++) {
        tempY = y;
        tempX = x + i % 2 * 160 + 40;

        if (i > 1) {
          tempY = y + 173;
        }
        piezo[i].showBar(tempX, tempY);
      }
    }
  }

  void showInterpret(int x, int y) {
    fill(255);
    text("Signal interpreté", x - 150, y - 170);
    rectMode(CENTER);
    fill(0);
    noStroke();
    rect(x, y, 300, 300);
    strokeWeight(2);
    stroke(255);
    noFill();
    rect(x - 75, y - 75, 150, 150);
    rect(x + 75, y - 75, 150, 150);
    rect(x - 75, y + 75, 150, 150);
    rect(x + 75, y + 75, 150, 150);

    if (padComplet(fsr[0], fsr[1])) {
      fill(255, 255, 0);
      noStroke();
      rect(x - 75, y - 100, 130, 50);
      fill(0);
      textAlign(CENTER);
      text("Public gauche", x - 75, y - 100);
    }

    if (padComplet(fsr[2], fsr[3])) {
      fill(255, 255, 0);
      noStroke();
      rect(x + 75, y - 100, 130, 50);
      fill(0);
      textAlign(CENTER);
      text("Public droite", x + 75, y - 100);
    }

    if (padComplet(fsr[4], fsr[5])) {
      fill(255, 255, 0);
      noStroke();
      rect(x - 75, y + 100, 130, 50);
      fill(0);
      textAlign(CENTER);
      text("Artiste gauche", x - 75, y + 100);
    }

    if (padComplet(fsr[6], fsr[7])) {
      fill(255, 255, 0);
      noStroke();
      rect(x + 75, y + 100, 130, 50);
      fill(0);
      textAlign(CENTER);
      text("Artiste droite", x + 75, y + 100);
    }

    if (piedPlein(sGauche)) {
      fill(255, 255, 0);
      noStroke();
      rect(x - 78, y, 100, 100);
      fill(0);
      textAlign(CENTER);
      text("Pied plein gauche", x - 100, y);
    }

    if (piedPlein(sDroite)) {
      fill(255, 255, 0);
      noStroke();
      rect(x + 75, y, 100, 100);
      fill(0);
      textAlign(CENTER);
      text("Pied plein droite", x + 75, y);
    }
  }

  boolean padComplet(Sensor p1, Sensor p2) {
    return p1.state && p2.state;
  }
  
  boolean glissementVerticalAvant(Sensor[] cote){
    boolean c = false;
    
    return c;
  }
}

float getMean(Sensor[] s) {
  for (int i = 0; i < s.length; i++) {
    println(s[i].read);
  }
  return 0;
}
