float minBoltWidth = 3;
float maxBoltWidth = 10;

float minJumpLength = 1;
float maxJumpLength = 10;

boolean stormMode = true;
boolean fadeStrikes = true;
boolean randomColors = false;
float maxTimeBetweenStrikes = 2000;
color boltColor;
color skyColor;

lightningBolt bolt;
float lastStrike = 0;
float nextStrikeInNms = 0;

boolean playThunder = false;
boolean useDing = false;
float meanDistance = 0;
ArrayList thunderTimes = new ArrayList();
float maxDTheta = PI/20;
float minDTheta = PI/30;
float maxTheta = PI/3;
float childGenOdds = 0.01;

class Raindrop extends Mode {
  ArrayList<Drop> drops;
  int NUM_DROPS = 300;
  lightningBolt bolt;
  Raindrop() {
    BG_COLOR = color(0, 0, 10, 20);
    drops = new ArrayList<Drop>();
    drops.add(new Drop(10, 10, 10, 1));
  }

  void bg() {
    background(BG_COLOR);
  }

  void display() {
    fill(255);
    for (int i = 0; i < drops.size(); i++) {
      //drops.get(i).display();
      drops.get(i).displayWithBlur();
      drops.get(i).update();

      if (drops.get(i).checkLimits()) {
        drops.remove(i);
      }
    }
  }

  void update() {
    if (drops.size() < NUM_DROPS) {
      //int r = int(random(0, 2));
      //if ((r % 2) == 0) {
      drops.add(new Drop(int(random(0, width)), 10, 10, 1));
      drops.add(new Drop(int(random(0, width)), 10, 10, 1));
              drops.add(new Drop(int(random(0, width)), 10, 10, 1));
      //}
    }
  }
}

class Drop {
  int pos[];
  int size;
  int screen;
  int speed;

  Drop(int x, int y, int size, int screen) {
    this.pos = new int[2];
    this.pos[0] = x;
    this.pos[1] = y;
    this.size = size;
    this.screen = screen;
    this.speed = int(random(4, 10));
  }

  void display() {
    fill(255);
    noStroke();
    if (this.screen == 1) {
      ellipse(this.pos[0], this.pos[1], 3, this.size);
    }
  }

  void displayWithBlur() {
    for (int i = 0; i < 5; i++) {
      fill(200, 200, 255, 20);
      noStroke();
      ellipse(pos[0], pos[1], 1 + i*2, 25 + i*2);
    }
  }

  void update() {
    this.pos[1] += this.speed;
  }

  boolean checkLimits() {
    if (screen == 1 && this.pos[1] > 400 - 25) {
      return true;
    } else return false;
  }
}

class lightningBolt {

  float lineWidth0, theta, x0, y0, x1, y1, x2, y2, straightJump, straightJumpMax, straightJumpMin, lineWidth;
  color myColor;
  lightningBolt(float x0I, float y0I, float width0, float theta0, float jumpMin, float jumpMax, color inputColor) {

    lineWidth0 = width0;
    lineWidth = width0;
    theta = theta0;
    x0 = x0I;
    y0 = y0I;
    x1 = x0I;
    y1 = y0I;
    x2 = x0I;
    y2 = y0I;
    straightJumpMin = jumpMin;
    straightJumpMax = jumpMax;
    myColor = inputColor;
    //it's a wandering line that goes straight for a while,
    //then does a jagged jump (large dTheta), repeats.
    //it does not aim higher than thetaMax
    //(where theta= 0 is down)
    straightJump = random(straightJumpMin, straightJumpMax);
  }

  //tells when the thunder should sound.
  float getThunderTime() {
    return (millis()+meanDistance*(1+random(-.1, .1)));
  }

  void draw()
  {
    while (y2<400 && (x2>0 && x2<width))
    {
      strokeWeight(2);

      theta += randomSign()*random(minDTheta, maxDTheta);
      if (theta>maxTheta)
        theta = maxTheta;
      if (theta<-maxTheta)
        theta = -maxTheta;

      straightJump = random(straightJumpMin, straightJumpMax);
      x2 = x1-straightJump*cos(theta-HALF_PI);
      y2 = y1-straightJump*sin(theta-HALF_PI);

      if (randomColors)
        myColor = slightlyRandomColor(myColor, straightJump);

      lineWidth = map(y2, height, y0, 1, lineWidth0);
      if (lineWidth<0)
        lineWidth = 0;
      stroke(255, 255, 255, 80);
      strokeWeight(lineWidth);
      line(x1, y1, x2, y2);
      x1=x2;
      y1=y2;

      //think about making a fork
      if (random(0, 1)<childGenOdds) {//if yes, have a baby!
        float newTheta = theta;
        newTheta += randomSign()*random(minDTheta, maxDTheta);
        if (theta>maxTheta)
          theta = maxTheta;
        if (theta<-maxTheta)
          theta = -maxTheta;
        //        nForks++;
        (new lightningBolt(x2, y2, lineWidth, newTheta, straightJumpMin, straightJumpMax, boltColor)).draw();
        //it draws the whole limb before continuing.
      }
    }
  }
}

int randomSign() //returns +1 or -1
{
  float num = random(-1, 1);
  if (num==0)
    return -1;
  else
    return (int)(num/abs(num));
}

color slightlyRandomColor(color inputCol, float length) {
  //float h = hue(inputCol);
  //h = (h+random(-length, length))%100;
  //return color(h, 99, 99);
  return color (255, 255, 255);
}

void keyPressed() {
  print(key);
  if (key == ' ') {
    bolt = new lightningBolt(random(0, width), 0, random(minBoltWidth, maxBoltWidth), 0, minJumpLength, maxJumpLength, boltColor);
    bolt.draw();
  }
}
