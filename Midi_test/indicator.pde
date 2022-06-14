int PIEZO_THRESHOLD = 10;
int SLIDE_DELAY = 200;
int SLIDE_OFF_DELAY = 300;

class FSR {
}

class Piezo {
}

class Pad {
  boolean state;
  int id;
  float x, y;
  int val, max, maxTime;
  int timer;
  color c1;
  color c2;

  Pad(int id, float x, float y) {
    this.id = id;
    this.x = x;
    this.y = y;
    this.c1 = color(255, 255, 225);
    this.c2 = color(0, 255, 0);
    this.maxTime = 3000;
    this.state = false;
  }

  void show(int tX, int tY) {
    rectMode(CORNER);
    fill(this.c2);
    rect(tX, tY - val + 127, 20, val);
    stroke(this.c1);
    strokeWeight(1);
    noFill();
    rect(tX, tY, 20, 127);
    if (millis() - this.timer < maxTime && max > 0) {
      fill(255, 0, 0);
      rect(tX, tY - max + 127, 20, 2);
    }
  }

  void setValue(int val) {
    this.val = val;
    state = false;
    if (val > PIEZO_THRESHOLD) {
      state = true;
    }
    if (val > max || (millis() - timer) > maxTime) {
      this.max = val;
      this.timer = millis();
    }
  }
}

class Slide {
  String name;
  boolean firstPad, secondPad;
  Pad p1, p2;
  int delay;
  int timer;
  //int PIEZO_THRESHOLD;

  Slide(String name, Pad p1, Pad p2) {
    this.name = name;
    this.firstPad = false;
    this.secondPad = false;
    this.delay = 100;
    this.p1 = p1;
    this.p2 = p2;
  }

  void eval() {
    if (p1.val > PIEZO_THRESHOLD && !p2.state) {
      firstPad = true;
      timer  = millis();
      
    }

    if (!p1.state && firstPad && !secondPad && p2.state && (millis() - timer) < SLIDE_DELAY) {
      secondPad = true;
    }

    if (millis() - timer > SLIDE_OFF_DELAY) {
      firstPad = false;
      secondPad = false;
    }
  }

  boolean isActive() {
    return firstPad && secondPad;
  }

  void show(int x, int y, int direction) {
    //fill(255);
    //strokeWeight(4);
    //line(x, y - 59, x, centerY + 100);
    //line(x, y + 50, centerX - 100, centerY + 100);
    //line(x, y + 50, centerX - 100, centerY + 100);
    //text(name, x, y);
  }
}

class indicator {

  float x, y;
  float centerX, centerY;
  float dotX, dotY;
  int size, square;
  color c;
  Pad[] piezo;
  Pad[] fsr;
  Slide[] slide;
  Queue log;

  indicator (int x, int y) {
    this.x = x;
    this.y = y;
    this.size = 10;
    this.centerX = x + 150;
    this.centerY = y + 150;
    this.c = color(255, 0, 0);
    this.square = 400;
    this.log = new Queue();
    this.fsr = new Pad[8];
    this.piezo = new Pad[4];
    this.slide = new Slide[4];
    for (int i = 0; i < 4; i++) {
      piezo[i] = new Pad(i, x - 120 + i * 40, 50);
    }

    fsr[0] = new Pad(0, -140, -115);
    fsr[1] = new Pad(1, -70, -115);
    fsr[2] = new Pad(2, 70, -115);
    fsr[3] = new Pad(3, 140, -115);
    fsr[4] = new Pad(4, -140, 115);
    fsr[5] = new Pad(5, -70, 115);
    fsr[6] = new Pad(6, 70, 115);
    fsr[7] = new Pad(7, 140, 115);

    slide[0] = new Slide("Glissement arriere gauche", fsr[0], fsr[4]);
    slide[1] = new Slide("Glissement arriere droite",  fsr[4], fsr[1]);
    slide[2] = new Slide("Glissement avant gauche", piezo[1], piezo[3]);
    slide[3] = new Slide("Glissement avant gauche", piezo[3], piezo[1]);
  }

  void show() {
    fill(this.c);
    noStroke();
    showBar(400);
    drawHeatMap(100);
    moveDot(800, 200);
    mainMap(width / 2, 600);
  }

  void drawGrid(int x, int y) {
    rectMode(CENTER);
    strokeWeight(2);
    stroke(255);
    noFill();
    rect(x, y, 150, 150);
    rect(x + 150, y, 150, 150);
    rect(x, y + 150, 150, 150);
    rect(x + 150, y + 150, 150, 150);
  }

  void drawHeatMap(int x) {
    rectMode(CENTER);
    strokeWeight(2);
    stroke(255);
    noFill();
    rect(x, 125, 150, 150);
    rect(x + 150, 125, 150, 150);
    rect(x, 275, 150, 150);
    rect(x + 150, 275, 150, 150);

    for (int i = 0; i < fsr.length; i++) {

      float tempX = x - 110 + 70 * (i % 4 + 1);
      float tempY = 200 - 110;

      if ((i > 1 && i < 4) || (i > 5)) {
        tempX += 20;
      }

      if (i >= 4) {
        tempY = 200 + 110;
      }

      noStroke();
      fill(255);
      rect(tempX, tempY, 50, 50);
      fill(255, 255 - map(fsr[i].val, 0, 127, 0, 255), 0);
      rect(tempX, tempY, map(fsr[i].val, 0, 127, 0, 50), map(fsr[i].val, 0, 127, 0, 50));
    }

    for (int i = 0; i < piezo.length; i++) {
      float tempX = x - 5 + 160 * (i % 2);

      float tempY = 200  - 50;

      if (i >= 2) {
        tempY = 200 + 50;
      }
      fill(255);
      ellipse(tempX, tempY, 50, 50);
      fill(255, 255 - map(piezo[i].val, 0, 127, 0, 255), 0);
      ellipse(tempX, tempY, map(piezo[i].val, 0, 127, 0, 50), map(piezo[i].val, 0, 127, 0, 50));
    }
  }

  void showBar(int x) {

    for (int i = 0; i < fsr.length; i++) {
      int tempY = 222;
      int tempX = x + i % 4 * 50;

      if (i < 4) {
        tempY = 50;
      }

      fsr[i].show(tempX, tempY);
    }
  }

  void handleNote(int note, int velocity) {

    switch (note) {

    case 1:
      piezo[0].setValue(velocity);
      break;

    case 2:
      piezo[2].setValue(velocity);
      break;

    case 3:
      piezo[3].setValue(velocity);
      break;

    case 4:
      piezo[1].setValue(velocity);
      break;

    case 74:
      this.x = map(velocity, 0, 127, square / 2, 50);
      this.y = map(velocity, 0, 127, square/ 2, 50);
      fsr[0].setValue(velocity);
      break;

    case 76:
      this.x = square / 2;
      this.y = map(velocity, 0, 127, square / 2, 50);
      fsr[1].setValue(velocity);
      break;

    case 78:
      this.x = square / 2;
      this.y = map(velocity, 0, 127, square / 2, 50);
      fsr[2].setValue(velocity);
      break;

    case 79:
      this.x = map(velocity, 0, 127, square / 2, square - 50);
      this.y = map(velocity, 0, 127, square / 2, 50);
      fsr[3].setValue(velocity);
      break;

    case 81:
      this.x = map(velocity, 0, 127, square / 2, 50);
      this.y = map(velocity, 0, 127, square / 2, square - 50);
      fsr[4].setValue(velocity);
      break;

    case 83:
      this.x = square / 2;
      this.y = map(velocity, 0, 127, square / 2, square - 50);
      fsr[5].setValue(velocity);
      break;

    case 85:
      this.x = square / 2;
      this.y = map(velocity, 0, 127, square / 2, (square * 3) / 4);
      fsr[6].setValue(velocity);
      break;

    case 86:
      this.x = map(velocity, 0, 127, square / 2, (square * 3) / 4);
      this.y = map(velocity, 0, 127, square / 2, (square * 3) / 4);
      fsr[7].setValue(velocity);
      break;

    default:
      this.x = square / 2;
      this.y = square / 2;
    }
  }

  void moveDot(int centerX, int centerY) {

    dotX = centerX;
    dotY = centerY;

    rectMode(CENTER);
    strokeWeight(2);
    stroke(255);
    noFill();
    rect(centerX - 100, centerY - 75, 150, 150);
    rect(centerX + 100, centerY - 75, 150, 150);
    rect(centerX - 100, centerY + 75, 150, 150);
    rect(centerX + 100, centerY + 75, 150, 150);
    fill(255);
    rect(centerX, centerY, 50, 300);

    fill(0, 255, 0);
    //gauche
    ellipse(centerX - 70, centerY - 115, size, size);
    ellipse(centerX - 140, centerY - 115, size, size);
    ellipse(centerX - 70, centerY + 115, size, size);
    ellipse(centerX - 140, centerY + 115, size, size);
    //droite
    ellipse(centerX + 70, centerY - 115, size, size);
    ellipse(centerX + 140, centerY - 115, size, size);
    ellipse(centerX + 70, centerY + 115, size, size);
    ellipse(centerX + 140, centerY + 115, size, size);

    //fsr 0
    dotX += map(fsr[0].val, 0, 127, 0, 180 / 2) * cos(PI * 0.78);
    dotY += map(fsr[0].val, 0, 127, 0, -180 / 2) * sin(PI * 0.78);

    //fsr 1
    dotX += map(fsr[1].val, 0, 127, 0, 134 / 2) * cos(PI * 2 / 3);
    dotY += map(fsr[1].val, 0, 127, 0, -134 / 2) * sin(PI * 2 / 3);

    ////fsr 2
    dotX += map(fsr[2].val, 0, 127, 0, 130 / 2) * cos(PI * 0.32);
    dotY += map(fsr[2].val, 0, 127, 0, -134 / 2) * sin(PI * 0.32);

    ////fsr 3
    dotX += map(fsr[3].val, 0, 127, 0, 180 / 2) * cos(PI * 0.22);
    dotY += map(fsr[3].val, 0, 127, 0, -180 / 2) * sin(PI * 0.22);

    //fsr 4
    dotX += map(fsr[4].val, 0, 127, 0, 180 / 2) * cos(PI * 0.78);
    dotY += map(fsr[4].val, 0, 127, 0, 180 / 2) * sin(PI * 0.78);

    //fsr 5
    dotX += map(fsr[5].val, 0, 127, 0, 134 / 2) * cos(PI * 2 / 3);
    dotY += map(fsr[5].val, 0, 127, 0, 134 / 2) * sin(PI * 2 / 3);

    ////fsr 6
    dotX += map(fsr[6].val, 0, 127, 0, 130 / 2) * cos(PI * 0.32);
    dotY += map(fsr[6].val, 0, 127, 0, 134 / 2) * sin(PI * 0.32);

    ////fsr 7
    dotX += map(fsr[7].val, 0, 127, 0, 180 / 2) * cos(PI * 0.22);
    dotY += map(fsr[7].val, 0, 127, 0, 180 / 2) * sin(PI * 0.22);


    fill(255, 0, 0);
    ellipse(dotX, dotY, size, size);
  }

  void mainMap(int centerX, int centerY) {
    rectMode(CENTER);
    textAlign(CENTER);
    strokeWeight(2);
    stroke(255);
    noFill();
    rect(centerX - 100, centerY - 75, 150, 150);
    rect(centerX + 100, centerY - 75, 150, 150);
    rect(centerX - 100, centerY + 75, 150, 150);
    rect(centerX + 100, centerY + 75, 150, 150);
    fill(255);
    rect(centerX, centerY, 50, 300);

    for (int i = 0; i < 4; i++){
      slide[i].eval();
    }
    
    if (slide[0].isActive()) {
      fill(255);
      strokeWeight(4);
      line(centerX - 100, centerY - 100, centerX - 100, centerY + 100);
      line(centerX - 120, centerY + 50, centerX - 100, centerY + 100);
      line(centerX - 80, centerY + 50, centerX - 100, centerY + 100);
      text("Glissement gauche", centerX - 100, centerY + 120);
    }

    if (slide[1].isActive()) {
      fill(255);
      strokeWeight(4);
      line(centerX - 100, centerY - 100, centerX - 100, centerY + 100);
      line(centerX - 120, centerY - 50, centerX - 100, centerY - 100);
      line(centerX - 80, centerY - 50, centerX - 100, centerY - 100);
      text("Glissement gauche", centerX - 100, centerY + 120);
    }
    
    //if (slide[2].isActive()) {
    //  fill(255);
    //  strokeWeight(4);
    //  line(centerX + 100, centerY - 100, centerX + 100, centerY + 100);
    //  line(centerX + 120, centerY + 50, centerX + 100, centerY + 100);
    //  line(centerX + 80, centerY + 50, centerX + 100, centerY + 100);
    //  text("Glissement gauche", centerX + 100, centerY + 120);
    //}


    if (pleinPied("double")) {
      fill(255, 255, 0);
      noStroke();
      rect(centerX, centerY, 300, 100);
      fill(0);
      text("Pied plein double", centerX, centerY);
    }
    if (pleinPied("gauche")) {
      fill(255, 255, 0);
      noStroke();
      rect(centerX - 100, centerY, 100, 100);
      fill(0);
      text("Pied plein gauche", centerX - 100, centerY);
    }

    if (pleinPied("droit")) {
      fill(255, 255, 0);
      noStroke();
      rect(centerX + 100, centerY, 100, 100);
      fill(0);
      text("Pied plein droit", centerX + 100, centerY);
    }

    if (padDouble("public gauche")) {
      fill(255, 255, 0);
      noStroke();
      rect(centerX - 100, centerY - 100, 100, 100);
      fill(0);
      text("Public Gauche", centerX - 100, centerY - 100);
    }

    if (padDouble("public droite")) {
      fill(255, 255, 0);
      noStroke();
      rect(centerX + 100, centerY - 100, 100, 100);
      fill(0);
      text("Public droit", centerX + 100, centerY - 100);
    }

    if (padDouble("artiste gauche")) {
      fill(255, 255, 0);
      noStroke();
      rect(centerX - 100, centerY + 100, 100, 100);
      fill(0);
      text("Artiste Gauche", centerX - 100, centerY + 100);
    }

    if (padDouble("artiste droite")) {
      fill(255, 255, 0);
      noStroke();
      rect(centerX + 100, centerY + 100, 100, 100);
      fill(0);
      text("Artiste droit", centerX + 100, centerY + 100);
    }
  }

  boolean padDouble(String pad) {

    switch(pad) {
    case "public gauche":
      return (fsr[0].state && fsr[1].state);

    case "public droite":
      return (fsr[2].state && fsr[3].state);

    case "artiste gauche":
      return (fsr[4].state && fsr[5].state);

    case "artiste droite":
      return (fsr[6].state && fsr[7].state);

    default:
      return false;
    }
  }

  boolean pleinPied(String pied) {
    if (pied == "gauche") {
      return(piezo[0].state && piezo[2].state);
    }

    if (pied == "droite") {
      return (piezo[1].state && piezo[3].state);
    }

    if (pied == "double") {
      return (piezo[0].state && piezo[1].state && piezo[2].state && piezo[3].state);
    }

    return false;
  }
}
