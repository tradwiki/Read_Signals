color C1 = color(150, 30, 0);
int NUM_FSR = 8;
int NUM_PIEZO = 4;
int SENSOR_STORED_READ_SIZE = 355;

int FSR_STATE_THRESHOLD = 10;
int PIEZO_STATE_THRESHOLD = 10;
int PLEIN_PIED_THRESHOLD = 10;
int PLEIN_PIED_MEAN = 50;
int FSR_MAX_TIME = 3000;
int PIEZO_MAX_TIME = 3000;

String[] FSR_ADDR = {"/FSR/PG", "/FSR/PG", "/FSR/PD", "/FSR/PD", "/FSR/AG", "/FSR/AG", "/FSR/AD", "/FSR/AD"};
String[] PIEZO_ADDR = {"/PIEZO/PG", "/PIEZO/PD", "/PIEZO/AG", "/PIEZO/AD"};

//int FSR_GRAPH_WIDTH = 350;
int MAX_BAR_TIME = 3000;

class Sensor {
  int id;
  String addr;
  String type;
  boolean state;
  int read, max;
  PFont font;
  int timer;
  int stateThreshold, maxTime;
  int[] storedReads;
  int readIndex;
  boolean pressed;

  Sensor(String type, int id, String addr) {
    this.type = type;
    this.id = id;
    this.addr = addr;
    this.read = 0;
    this.state = false;
    this.font = createFont("Noto Serif", 14);
    this.storedReads = new int[SENSOR_STORED_READ_SIZE];
    this.readIndex = 0;
    this.pressed = false;

    if (type == "fsr") {
      this.stateThreshold = FSR_STATE_THRESHOLD;
      this.maxTime = FSR_MAX_TIME;
    } else {
      this.stateThreshold = PIEZO_STATE_THRESHOLD;
      this.maxTime = PIEZO_MAX_TIME;
    }
  }
  
  boolean newPress(){
    return (read > 0 && storedReads[readIndex - 1] == 0);
  }

  boolean isPressed() {
    return this.pressed;
  }

  int getId() {
    return this.id;
  }

  int getRead() {
    return this.read;
  }
  
  void printRead() {
    println(storedReads);
  }

  void advanceRead() {
    storedReads[readIndex] = read;
    
    if (pressed && read == 0){
      pressed = false;
    }
    
    if (!pressed && read != 0){
      pressed = true;
    }
    
    this.readIndex = (this.readIndex + 1) % SENSOR_STORED_READ_SIZE;
  };

  void setRead(int r) {
    this.read = r;

    if (r > max) {
      max = r;
      timer = millis();
    }
  }

  void showGraph1(int x, int y, float graphX, int w, int h) {
    fill(0, 0, 0);
    rect(x, y, screenWidth, h);

    float graphY;
    fill(255, 0, 0);
    noStroke();
    if (type == "fsr") {
      fill(255, 255, 255);
    } else {
      fill(255, 0, 0);
    }
    for (int i = 0; i < SENSOR_STORED_READ_SIZE / 2; i++) {
      graphY = map(storedReads[i], 0, 127, 0, h - 2);
      rect(x + i * 4, y - graphY + h - 2, 2, graphY);
    }
  }

  void showGraph2(int x, int y, float graphX, int w, int h) {
    fill(0, 0, 0);
    rect(x, y, screenWidth, h);

    float graphY;
    fill(255, 0, 0);
    noStroke();
    if (type == "fsr") {
      fill(255, 255, 255);
    } else {
      fill(255, 0, 0);
    }
    for (int i = SENSOR_STORED_READ_SIZE / 2; i < SENSOR_STORED_READ_SIZE; i++) {
      graphY = map(storedReads[i], 0, 127, 0, h - 2);
      rect(x + i * 4 - screenWidth, y - graphY + h - 2, 2, graphY);
    }
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

  //void emptyStoreReads() {
  //  for (int i = 0; i < SENSOR_STORED_READ_SIZE; i++) {
  //    storedReads[i] = 0;
  //  }
  //}
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
  int bpm;
  String beat;

  Planche() {
    //this.oscP5 = new OscP5(this, 1100);
    print(PFont.list());
    this.font = createFont("Noto Serif", 14);
    this.pauseGraph = false;
    this.pauseBar = false;
    this.fsr = new Sensor[NUM_FSR];
    this.piezo = new Sensor[NUM_PIEZO];
    this.mean = 0;
    this.bpm = 0;
    this.beat = "";

    for (int i = 0; i < NUM_FSR; i++) {
      fsr[i] = new Sensor("fsr", i, FSR_ADDR[i]);
    }

    for (int i = 0; i < NUM_PIEZO; i++) {
      piezo[i] = new Sensor("piezo", i, PIEZO_ADDR[i]);
    }
  }

  int getBpm() {
    return bpm;
  }
  
  String gertBeat(){
    return beat;
  }
  
  void update(){
    for (int i = 0; i < NUM_FSR; i++){
      fsr[i].advanceRead();
    }
    
    for (int i = 0; i < NUM_PIEZO; i++){
      piezo[i].advanceRead();
    }
  }

  void showGrid(float x, float y) {
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
  }
  
    void showGridMondrian(float x, float y) {
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
      fill(mondrian[floor(i / 2)]);
      rect(tempX, tempY, 50, 50);
      fill(255, 255, 255);
      rect(tempX + random(-15, 15), tempY + random(-15, 15), map(fsr[i].read, 0, 127, 0, 50), map(fsr[i].read, 0, 127, 0, 45));
    }

    for (int i = 0; i < piezo.length; i++) {
      float tempX = x - 80 + 160 * (i % 2);

      float tempY = y  - 50;

      if (i >= 2) {
        tempY = y + 50;
      }
      fill(255);
      ellipse(tempX, tempY, 50, 50);
      fill(255, 123, 0);
      ellipse(tempX, tempY, map(piezo[i].read, 0, 127, 0, 50), map(piezo[i].read, 0, 127, 0, 50));
    }
  }


  void handleOSC(OscMessage theOscMessage) {

    for (int i = 0; i < NUM_FSR; i++) {
      if (fsr[i].addr.equals(theOscMessage.addrPattern())) {
        //get left and right values
        if (fsr[i].id % 2 == 0) {
          fsr[i].setRead(theOscMessage.get(0).intValue());
        } else { 
          fsr[i].setRead(theOscMessage.get(1).intValue());
        }
      }
    }

    for (int i = 0; i < NUM_PIEZO; i++) {
      if (piezo[i].addr.equals(theOscMessage.addrPattern())) {
        piezo[i].setRead(theOscMessage.get(0).intValue());
      }
    }
    if (theOscMessage.addrPattern().equals("/tempo")) {
      bpm = theOscMessage.get(0).intValue();
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


  void mur(int x, int y) {
    if (!pauseBar) {
      int tempX, tempY;
      tempY = y + 290;
      tempX = x + screenWidth / 2 - 200;
      fsr[0].showBar(tempX, tempY);
      fsr[4].showBar(tempX, tempY + screenHeight);
      tempX = x + 355 - 100;
      fsr[1].showBar(tempX, tempY);
      fsr[5].showBar(tempX, tempY + screenHeight);
      tempX = x + screenWidth / 2 + 100;
      fsr[2].showBar(tempX, tempY);
      fsr[6].showBar(tempX, tempY + screenHeight);
      tempX = x + screenWidth / 2 + 200;
      fsr[3].showBar(tempX, tempY);
      fsr[7].showBar(tempX, tempY + screenHeight);
      tempX = x + screenWidth / 2 + 60;

      tempY = y + 290;
      tempX = x + screenWidth / 2 - 150;
      piezo[0].showBar(tempX, tempY);
      piezo[2].showBar(tempX, tempY + screenHeight);
      tempX = x + screenWidth / 2 + 150;
      piezo[1].showBar(tempX, tempY);
      piezo[3].showBar(tempX, tempY + screenHeight);
      tempX = x + 420 + 60;
    }

    if (!pauseGraph) {

      int w = screenWidth;
      int h = 20;


      for (int i = 0; i < NUM_FSR; i++) {
        fsr[i].showGraph1(x, y + i * ( h + 10) + 20, graphX, w, h);
        fsr[i].showGraph2(x, y + i * ( h + 10) + 20 + screenHeight, graphX, w, h);
      }
      for (int i = 0; i < NUM_PIEZO; i++) {
        piezo[i].showGraph1(x, y + i * ( h + 40) + 35, graphX, w, h);
        piezo[i].showGraph2(x, y + i * ( h + 40) + 35 + screenHeight, graphX, w, h);
      }
    }


    stroke(255, 255, 255);
    if (fsr[0].readIndex * 4 < screenWidth) {
      line((fsr[0].readIndex * 4) % screenWidth, 20, (fsr[0].readIndex * 4) % screenWidth, 250);
    } else {
      line((fsr[0].readIndex * 4) % screenWidth, 20 + screenHeight, (fsr[0].readIndex * 4) % screenWidth, 250 + screenHeight);
    }
  }
}
