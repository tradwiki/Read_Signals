class Pad {
  int id;
  float x, y;
  int val;
  color c1;
  color c2;

  Pad(int id, float x, float y, int c) {
    this.id = id;
    this.x = x;
    this.y = y;
    this.c1 = color(255, 255, c);
    this.c2 = color(0, 255, 0);
  }

  void show() {
    fill(this.c2);
    rect(x, y - val + 142, 20, 5);
    stroke(this.c1);
    strokeWeight(1);
    noFill();
    rect(x, y, 20, 147);
  }

  void setValue(int val) {
    this.val = val;
  }
}

class indicator {
  float x, y;
  int size, square;
  color c;
  Pad[] p;

  indicator (int x, int y) {
    this.x = x;
    this.y = y;
    this.size = 10;
    this.c = color(255, 0, 0);
    this.square = 400;
    this.p = new Pad[8];
    for (int i = 0; i < 8; i++) {
      p[i] = new Pad(i, 400 + i * 30, 150, 100);
    }
  }

  void show() {
    fill(this.c);
    noStroke();
    ellipse(x, y, size, size);

    for (int i = 0; i < 8; i++) {
      p[i].show();
    }
  }

  void drawGrid() {
    background(0);
    strokeWeight(2);
    stroke(255);
    noFill();
    rect(50, 50, (square)/2 - 50, square / 2 - 50);
    rect(square/2, 50, square/2 - 50, square / 2 - 50);
    rect(50, square / 2, square/2 - 50, square / 2 - 50);
    rect(square/2, square / 2, square/2 - 50, square / 2 - 50);
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
