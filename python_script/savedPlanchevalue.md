color C1 = color(150, 30, 0);
int NUM_FSR = 8;
int NUM_PIEZO = 4;
int SENSOR_STORED_READ_SIZE = 400;

int FSR_STATE_THRESHOLD = 10;
int PIEZO_STATE_THRESHOLD = 10;
int PLEIN_PIED_THRESHOLD = 10;
int PLEIN_PIED_MEAN = 50;
int FSR_MAX_TIME = 3000;
int PIEZO_MAX_TIME = 3000;

int[] FSR_NOTES = {74, 76, 78, 79, 81, 83, 85, 86};
int[] PIEZO_NOTES = {100, 101, 102, 103};

//int FSR_GRAPH_WIDTH = 350;
int MAX_BAR_TIME = 3000;

class Sensor {
  int id, note;
  String type;
  boolean state;
  int read, max;
  PFont font;
  int timer;
  int stateThreshold, maxTime;
  int[] storedReads;
  int readIndex;

  Sensor(String type, int id, int note) {
    this.type = type;
    this.id = id;
    this.note = note;
    this.read = 0;
    this.state = false;
    this.font = createFont("Noto Serif", 14);
    this.storedReads = new int[SENSOR_STORED_READ_SIZE];
    this.readIndex = 0;

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

  void advanceRead() {
    storedReads[readIndex] = read;
    readIndex = (readIndex + 1) % SENSOR_STORED_READ_SIZE;
  };

  void setRead(int r) {

  }
  
  void handleOSC(OscMessage theOscMessage){
    if (!(theOscMessage.addrPattern().equals(this.prevTap))) {
      this.prevTap = theOscMessage.addrPattern();

      int x, y;
      
      switch(prevTap) {
      case "/FSR/PG":
        x = int(random(0, screenWidth / 2));
        y = int(random(0, screenHeight / 2));
        break;
      case "/FSR/PD":
        x = int(random(screenWidth / 2, screenWidth));
        y = int(random(0, screenHeight / 2));
        break;
      case "/FSR/AG":
        x = int(random(0, screenWidth / 2));
        y = int(random(screenHeight/ 2, screenHeight));
        break;
      case "/FSR/AD":
        break;
      default:
      }
    }
  }

  void showGraph(int x, int y, float graphX, int w, int h) {
    noStroke();
    textFont(font);
    fill(255);
    text(type + id, x - 30, y + h);
    //noFill();
    //strokeWeight(2);
    fill(255);
    rectMode(CORNER);
    rect(x, y, w, h);
    float graphY;
    fill(C1);
    noStroke();

    for (int i = 0; i < readIndex; i++) {
      graphY = map(storedReads[i], 0, 127, 0, h - 5);
      rect(x + i * 2, y - 2 - graphY + h, 2, 2);
    }
  }

  void showGraph2(int x, int y, float graphX, int w, int h) {
    noStroke();
    fill(255);
    rectMode(CORNER);
    rect(x, y, SENSOR_STORED_READ_SIZE * 2, h);
    float graphY;
    fill(C1);
    noStroke();

    for (int i = 0; i < 400; i++) {
      graphY = map(storedReads[i], 0, 127, 0, h - 5);
      rect(x + i * 2, y - 2 - graphY + h, 2, graphY);
    }

    fill(C1);
    rect(x + readIndex * 2, y, 5, 35);
  }

  void showGraph3(int x, int y, float graphX, int w, int h) {
    noStroke();
    textFont(font);
    fill(255);
    text(type + id, x - 30, y + h);
    //noFill();
    //strokeWeight(2);
    fill(255);
    rectMode(CORNER);
    rect(x, y, SENSOR_STORED_READ_SIZE * 2, h);
    float graphY;
    fill(0, 123, 0);
    noStroke();

    for (int i = readIndex / 2; i < readIndex; i++) {
      graphY = map(storedReads[i], 0, 127, 0, h - 5);
      rect(x + i * 2, y - 2 - graphY + h, 2, graphY);
    }

    //fill(255, 255, 255);
    rect(x + readIndex * 2, y, 2, 70);
  }

  void showBar(int x, int y) {
    rectMode(CORNER);
    noStroke();
    fill(255);
    int size = 100;
    rect(x, y, 20, size);
    fill(0, 255, 0);
    float level = map(read, 0, 127, 0, size);
    rect(x, y - level + size, 20, level);
    stroke(255);
    //stroke(0);
    fill(C1);
    float mappedMax = map(max, 0, 127, 0, size);
    noStroke();
    rect(x, y - mappedMax + size, 20, 3);
    if (millis() - this.timer > maxTime && max > 1) {
      max = 1;
    }
  }

  void emptyStoreReads() {
    for (int i = 0; i < SENSOR_STORED_READ_SIZE; i++) {
      storedReads[i] = 0;
    }
  }
}

class Planche {
  //OscP5 oscP5;
  Sensor[] fsr;
  Sensor[] piezo;
  Sensor[] sGauche, sDroite;
  float graphX;
  boolean pauseGraph, pauseBar;
  float mean;
  PFont font;

  Planche() {
    //this.oscP5 = new OscP5(this, 1100);
    print(PFont.list());
    this.font = createFont("Noto Serif", 14);
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
    //text("Senseurs actifs", x - 150, y - 160);
    rectMode(CENTER);
    stroke(255);
    noFill();
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
    
        if (padComplet(fsr[0], fsr[1])) {
      fill(255, 255, 0);
      noStroke();
      rect(x - 75, y - 100, 130, 50);
      fill(0);
      textAlign(CENTER);
      text("Public cour", x - 75, y - 100);
    }

    if (padComplet(fsr[2], fsr[3])) {
      fill(255, 255, 0);
      noStroke();
      rect(x + 75, y - 100, 130, 50);
      fill(0);
      textAlign(CENTER);
      text("Public jardin", x + 75, y - 100);
    }

    if (padComplet(fsr[4], fsr[5])) {
      fill(255, 255, 0);
      noStroke();
      rect(x - 75, y + 100, 130, 50);
      fill(0);
      textAlign(CENTER);
      text("Artiste cour", x - 75, y + 100);
    }

    if (padComplet(fsr[6], fsr[7])) {
      fill(255, 255, 0);
      noStroke();
      rect(x + 75, y + 100, 130, 50);
      fill(0);
      textAlign(CENTER);
      text("Artiste jardin", x + 75, y + 100);
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

  void restartGraph(int x, int y, int w, int h) {
    fill(123);
    //stroke(0, 255, 0);
    rectMode(CENTER);
    graphX = 0;
    rect(x, y, w, 75 * NUM_FSR + 100);

    //for (int i = 0; i < NUM_FSR; i++ ) {
    //  fsr[i].emptyStoreReads();
    //}
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

  void showGraph(int x, int y, int w, int h) {
    fill(255);
    textAlign(LEFT);
    //text("Signal dans le temps", x, y - 30);
    if (!pauseGraph) {
      graphX++;

      if (graphX > w) {
        restartGraph(x, y, w, h * 8);
        //planche.restartGraph(width / 2, height / 2, GRAPH_WIDTH, GRAPH_HEIGHT);
      }

      for (int i = 0; i < NUM_FSR; i++) {
        fsr[i].advanceRead();
        fsr[i].showGraph2(x, y + i * ( h + 30), graphX, w, h);
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
        //fsr[i].sendOsc();
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

  void showBarVertical(int x, int y) {
    fill(255);
    textAlign(LEFT);
    text("Niveaux senseurs", x, y - 20);
    if (!pauseBar) {
      int tempX, tempY;
      for (int i = 0; i < NUM_FSR; i++) {
        tempY = y;
        tempX = x + i * 80;


        fsr[i].showBar(tempX, tempY);
      }

      for (int i = 0; i < NUM_PIEZO; i++) {
        tempY = y;
        tempX = x + i * 160 + 40;
        piezo[i].showBar(tempX, tempY);
      }
    }
  }

  void showInterpret(int x, int y) {
    fill(255);
    //text("Signal interpreté", x - 150, y - 170);
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

  void mur2(int x, int y) {
    if (!pauseBar) {
      int tempX, tempY;
      //for (int i = 0; i < NUM_FSR; i++) {
      //  tempY = y + 290;
      //  tempX = x + i * 80  + 100;
      //  fsr[i].showBar(tempX, tempY);
      //}
      tempY = y + 290;
      tempX = x + 80 - 30;
      fsr[0].showBar(tempX, tempY);
      tempX = x + 160 - 30;
      fsr[1].showBar(tempX, tempY);
      tempX = x + 240 - 30;
      fsr[2].showBar(tempX, tempY);
      tempX = x + 320 - 30;
      fsr[3].showBar(tempX, tempY);
      tempX = x + 380 + 60;
      fsr[6].showBar(tempX, tempY);
      tempX = x + 460 + 60;
      fsr[7].showBar(tempX, tempY);
      tempX = x + 580 + 60;
      fsr[4].showBar(tempX, tempY);
      tempX = x + 660 + 60;
      fsr[5].showBar(tempX, tempY);

      //for (int i = 0; i < NUM_PIEZO; i++) {
    //  tempY = y + 290;
    //  tempX = x + i * 160 + 40 + 100;
    //  piezo[i].showBar(tempX, tempY);
    //}
    tempY = y + 290;
    tempX = x + 120 - 30;
    piezo[0].showBar(tempX, tempY);
    tempX = x + 280 - 30;
      piezo[1].showBar(tempX, tempY);
    tempX = x + 420 + 60;
    piezo[3].showBar(tempX, tempY);
    tempX = x + 620 + 60;
    piezo[2].showBar(tempX, tempY);
    //}
  }

  if (!pauseGraph) {

    int w = 800;
    int h = 30;
    graphX++;

    if (graphX > w) {
      restartGraph(x, y, w, h * 8);
      //planche.restartGraph(width / 2, height / 2, GRAPH_WIDTH, GRAPH_HEIGHT);
    }

    for (int i = 0; i < NUM_FSR; i++) {
      fsr[i].advanceRead();
      fsr[i].showGraph2(x, y + i * ( h + 5), graphX, w, h);
    }
  }
}

boolean padComplet(Sensor p1, Sensor p2) {
  return p1.state && p2.state;
}

boolean glissementVerticalAvant(Sensor[] cote) {
  boolean c = false;

  return c;
}
}

float getMean(Sensor[] s) {
  for (int i = 0; i < s.length; i++) {
    println(s[i].read);
  }
  return 0;
<!-- } -->