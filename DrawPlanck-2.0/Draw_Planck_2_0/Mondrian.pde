//credit https://openprocessing.org/sketch/1587022
color black_ = color(4, 16, 21);
color[] mondrian = {color(175, 108, 56), color(12, 64, 138), color(177, 79, 118), color(253, 188, 0)};

class Mondrian extends Mode {
  float n;
  float n_;
  float[] GRID_POS = {screenWidth / 2, screenHeight * 2.5};
  Canvas canvas;
  color bg_color;
  boolean foundBeat;
  String lastNote;
  int prevPad;

  Mondrian() {

    n = 0.04;
    n_ = 0.04;
    canvas = new Canvas();
    bg_color = color(0, 0, 0);
    foundBeat = false;
    lastNote = "";
    prevPad = -1;
  }

  void display() {
    canvas.display();
    fill(bg_color);
    rect(0, screenHeight * 2, screenWidth, screenWidth);
    planche.showGridMondrian(GRID_POS[0], GRID_POS[1]);
  }

  void update() {
    canvas.update();
  }

  void handleOSC(OscMessage theOscMessage) {
    if (!foundBeat) {
      if (theOscMessage.checkAddrPattern("/FSR/PG") && prevPad != 0) {
        prevPad = 0;
        canvas.change = true;
      }
      if (theOscMessage.checkAddrPattern("/FSR/PD") && prevPad != 1) {
        prevPad = 1;
        canvas.change = true;
      }
      if (theOscMessage.checkAddrPattern("/FSR/AG") && prevPad != 2) {
        prevPad = 2;
        canvas.change = true;
      }
      if (theOscMessage.checkAddrPattern("/FSR/AD") && prevPad != 3) {
        prevPad = 3;
        canvas.change = true;
      }
      if (theOscMessage.checkAddrPattern("/pattern/On")) {
        foundBeat = true;
        canvas.accent_color = color(0, 0, 0);
        canvas.bg_color = color(255, 255, 255);
        lastNote = theOscMessage.get(0).stringValue();
      }
    } else {
      if (theOscMessage.checkAddrPattern(lastNote)) {
        canvas.change = true;
      }
      if (theOscMessage.checkAddrPattern("/pattern/Off")) {
        foundBeat = false;
        canvas.change = false;
        prevPad = -1;
        canvas.bg_color = color(0, 0, 0);
        canvas.accent_color = color(255, 255, 255);
      }
    }
  }
}

class Canvas {
  float n = 0.04;
  float n_ = 0.04;
  int l = screenHeight - 50;
  int w = screenWidth;
  int h = screenHeight;
  int countDown;
  int countDownTime = 50;
  boolean change;
  color accent_color, bg_color;

  Canvas() {
    countDown = -1;
    //foundBeat = false;
    change = true;
    accent_color = color(255, 255, 255);
    bg_color = color(0, 0, 0);
  }

  void display() {
    fill(0, 0, 0);
  }

  void update() {

    if (change) {
      //for (int offSet = 0; offSet < 2; offSet++) {
      countDown = countDownTime;
      //background(243, 241, 242, 1);
      background(bg_color);

      float r = l - l / 6;
      float r_ = l;

      for (int i = 0; i < n * l; i++) {
        createSquare(
          (r / 2) * sqrt(random(1)) * cos(random(TAU)) + w / 2, 
          (r / 2) * sqrt(random(1)) * sin(random(TAU)) + h / 2, 
          random(l / 10, l / 7), 
          mondrian[floor(random(mondrian.length))]
          );
      }

      for (int i = 0; i < n * l; i++) {
        createSquare(
          (r / 2) * sqrt(random(1)) * cos(random(TAU)) + w / 2, 
          (r / 2) * sqrt(random(1)) * sin(random(TAU)) + h / 2 + screenHeight, 
          random(l / 10, l / 7), 
          mondrian[floor(random(mondrian.length))]
          );
      }

      for (int j = 0; j < n_ * l; j++) {
        push();
        PVector v = new PVector(
          (r_ / 2) * sqrt(random(1)) * cos(random(TAU)) + w / 2, 
          (r_ / 2) * sqrt(random(1)) * sin(random(TAU)) + h / 2
          );
        float w_ = l / 60;
        float h_ = random(l / 30, l / 20);
        noStroke();
        translate(v.x, v.y);
        rectMode(CENTER);
        fill(accent_color);
        if (random(1) < 0.5) {
          rect(0, 0, w_, h_);
        } else {
          rect(0, 0, h_, w_);
        }
        pop();
      }

      for (int j = 0; j < n_ * l; j++) {
        push();
        PVector v = new PVector(
          (r_ / 2) * sqrt(random(1)) * cos(random(TAU)) + w / 2, 
          (r_ / 2) * sqrt(random(1)) * sin(random(TAU)) + h / 2
          );
        float w_ = l / 60;
        float h_ = random(l / 30, l / 20);
        noStroke();
        translate(v.x, v.y);
        //if (random(1) < 0.5) {
        //  rotate(PI / 2);
        //}
        rectMode(CENTER);
        fill(accent_color);
        if (random(1) < 0.5) {
          rect(0, screenHeight, w_, h_);
        } else {
          rect(0, screenHeight, h_, w_);
        }
        pop();
      }
      change = false;
    } else {
      countDown--;
    }
  }
}



void createSquare(float x, float y, float l, color c) {
  push();
  rectMode(CENTER);
  noStroke();
  fill(c);
  rect(x, y, l, l);
  pop();
}
