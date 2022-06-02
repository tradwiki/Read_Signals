class Pad {
  int id;
  float x, y;
  int val, max, maxTime;
  int timer;
  color c1;
  color c2;

  Pad(int id, float x, float y, int c) {
    this.id = id;
    this.x = x;
    this.y = y;
    this.c1 = color(255, 255, 225);
    this.c2 = color(0, 255, 0);
    this.maxTime = 3000;
  }

  void show() {
    rectMode(CORNER);
    fill(this.c2);
    rect(x, y - val + 127, 20, val);
    stroke(this.c1);
    strokeWeight(1);
    noFill();
    rect(x, y, 20, 127);
    if (millis() - this.timer < maxTime && max > 0) {
      fill(255, 0, 0);
      rect(x, y - max + 127, 20, 2);
    }
  }

  void setValue(int val) {
    this.val = val;

    if (val > max || (millis() - timer) > maxTime) {
      this.max = val;
      this.timer = millis();
    }
  }
}

class indicator {
  float x, y;
  float centerX, centerY;
  float dotX, dotY;
  int size, square;
  color c;
  Pad[] p;

  indicator (int x, int y) {
    this.x = x;
    this.y = y;
    this.size = 10;
    this.centerX = x + 150;
    this.centerY = y + 150;
    this.c = color(255, 0, 0);
    this.square = 400;
    this.p = new Pad[8];
    for (int i = 0; i < 4; i++) {
      p[i] = new Pad(i, x - 120 + i * 40, 50, 100);
    }
    for (int i = 4; i < 8; i++) {
      p[i] = new Pad(i, x - 120 + (i - 4) * 40, 225, 100);
    }
  }

  void show() {
    fill(this.c);
    noStroke();
    ellipse(dotX, dotY, size, size);

    for (int i = 0; i < 8; i++) {
      p[i].show();
    }
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

  void drawHeatMap(int x, int y) {
    rectMode(CENTER);
    strokeWeight(2);
    stroke(255);
    rect(x, y, 150, 150);
    rect(x + 150, y, 150, 150);
    rect(x, y + 150, 150, 150);
    rect(x + 150, y + 150, 150, 150);

    noStroke();
    fill(255);
    rect(x - 40, y - 40, 50, 50);
    fill(255, 255 - map(p[0].val, 0, 127, 0, 255), 0);
    rect(x - 40, y - 40, map(p[0].val, 0, 127, 0, 50), map(p[0].val, 0, 127, 0, 50));

    fill(255);
    rect(x + 40, y - 40, 50, 50);
    fill(255, 255 - map(p[1].val, 0, 127, 0, 255), 0);
    rect(x + 40, y - 40, map(p[1].val, 0, 127, 0, 50), map(p[1].val, 0, 127, 0, 50));
    
    fill(255);
    rect(x + 110, y - 40, 50, 50);
    fill(255, 255 - map(p[2].val, 0, 127, 0, 255), 0);
    rect(x + 110, y - 40, map(p[2].val, 0, 127, 0, 50), map(p[2].val, 0, 127, 0, 50));
    
    fill(255);
    rect(x + 190, y - 40, 50, 50);
    fill(255, 255 - map(p[3].val, 0, 127, 0, 255), 0);
    rect(x + 190, y - 40, map(p[3].val, 0, 127, 0, 50), map(p[3].val, 0, 127, 0, 50));
    
    fill(255);
    rect(x - 40, y + 185, 50, 50);
    fill(255, 255 - map(p[4].val, 0, 127, 0, 255), 0);
    rect(x - 40, y + 185, map(p[4].val, 0, 127, 0, 50), map(p[4].val, 0, 127, 0, 50));
    
    fill(255);
    rect(x + 40, y + 185, 50, 50);
    fill(255, 255 - map(p[5].val, 0, 127, 0, 255), 0);
    rect(x + 40, y + 185, map(p[5].val, 0, 127, 0, 50), map(p[5].val, 0, 127, 0, 50));
    
    fill(255);
    rect(x + 110, y + 185, 50, 50);
    fill(255, 255 - map(p[6].val, 0, 127, 0, 255), 0);
    rect(x + 110, y + 185, map(p[6].val, 0, 127, 0, 50), map(p[6].val, 0, 127, 0, 50));
    
    fill(255);
    rect(x + 185, y + 185, 50, 50);
    fill(255, 255 - map(p[7].val, 0, 127, 0, 255), 0);
    rect(x + 185, y + 185, map(p[7].val, 0, 127, 0, 50), map(p[7].val, 0, 127, 0, 50));

    stroke(255);
    noFill();
    ellipse(x, y + 10, 50, 50);
    ellipse(x + 148, y + 10, 50, 50);
    ellipse(x, y + 130, 50, 50);
    ellipse(x + 148, y + 130, 50, 50);
  }

  void handleNote(int note, int velocity) {
    switch (note) {
    case 74:
      this.x = map(velocity, 0, 127, square / 2, 50);
      this.y = map(velocity, 0, 127, square/ 2, 50);
      p[0].setValue(velocity);
      break;

    case 76:
      this.x = square / 2;
      this.y = map(velocity, 0, 127, square / 2, 50);
      p[1].setValue(velocity);
      break;

    case 78:
      this.x = square / 2;
      this.y = map(velocity, 0, 127, square / 2, 50);
      p[2].setValue(velocity);
      break;

    case 79:
      this.x = map(velocity, 0, 127, square / 2, square - 50);
      this.y = map(velocity, 0, 127, square / 2, 50);
      p[3].setValue(velocity);
      break;

    case 81:
      this.x = map(velocity, 0, 127, square / 2, 50);
      this.y = map(velocity, 0, 127, square / 2, square - 50);
      p[4].setValue(velocity);
      break;

    case 83:
      this.x = square / 2;
      this.y = map(velocity, 0, 127, square / 2, square - 50);
      p[5].setValue(velocity);
      break;

    case 85:
      this.x = square / 2;
      this.y = map(velocity, 0, 127, square / 2, (square * 3) / 4);
      p[6].setValue(velocity);
      break;

    case 86:
      this.x = map(velocity, 0, 127, square / 2, (square * 3) / 4);
      this.y = map(velocity, 0, 127, square / 2, (square * 3) / 4);
      p[7].setValue(velocity);
      break;


    default:
      this.x = square / 2;
      this.y = square / 2;
    }
  }
}
