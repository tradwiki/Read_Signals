float[] GRID_POS = {screenWidth / 2, screenHeight * 2.5};
class Reboisons extends Mode {
  private ArrayList<Branch> branch;
  private float offset;
  private int count;
  private int s_color;
  private float s_weight;
  private boolean draw;

  PImage vdj_logo;
  PImage ae_logo;
  PImage bg_floor;
  PImage bg_image1;
  PImage bg_image2;
  long drawStart;

  static final int BRANCH_COLOR_CHANGE = 50;

  int Y_AXIS = 1;
  int X_AXIS = 2;
  color b1, b2, b3, b4;
  int prevPad;
 

  public Reboisons() {
    branch = new ArrayList<Branch>();
    offset = -90.0;
    prevPad = -1;

    bg_image1 = loadImage("Tree_bg.png");
    bg_image2 = loadImage("carbone_riverain.png");
    ae_logo = loadImage("ae.png");
    bg_floor = loadImage("grass_floor.png");

    bg_image1.resize(screenWidth, screenHeight);
    ae_logo.resize(ae_logo.width/ 4, ae_logo.height / 4);

    branch.add(new Branch(screenWidth / 2, screenHeight, screenWidth / 2, screenHeight - 80.0, 80.0, 0.0));
    count = 0;
    s_color = 0;
    s_weight = 0;
    //colorize = false;
    draw = false;

    image(bg_image1, 0, 0);
    image(bg_image2, 0, screenHeight);
    image(ae_logo, 0, 20);
  }

  void bg() {
    image(bg_floor, 0, screenHeight * 2);
  }

  void display() {
    imageMode(CENTER);
    //image(ae_logo, 2*width/5, height/4);
    //image(vdj_logo, 3*width/5, height/4);
    imageMode(CORNER);

    colorMode(RGB, 255, 255, 255, 100);
    if (draw || System.currentTimeMillis() - drawStart < 50) {
      for (int i = 0; i < branch.size(); i++) {
        branch.get(i).Render();
        branch.get(i).Update();
      }
    }

    planche.showGrid(GRID_POS[0], GRID_POS[1]);
  }

  void update() {
    //draw = false;
  }

  void handleOSC(OscMessage theOscMessage) {
    if (theOscMessage.checkAddrPattern("/FSR/PG") && prevPad != 0) {
      draw = true;
      drawStart = System.currentTimeMillis();
    }
    else if (theOscMessage.checkAddrPattern("/FSR/PD") && prevPad != 1) {
      draw = true;
      drawStart = System.currentTimeMillis();
    }
    else if (theOscMessage.checkAddrPattern("/FSR/AG") && prevPad != 2) {
      draw = true;
      drawStart = System.currentTimeMillis();
    }
    else if (theOscMessage.checkAddrPattern("/FSR/AD") && prevPad != 3) {
      //System.out.println("pad detected " + pad.name + "\n branch size: " + branch.size());
      draw = true;
      drawStart = System.currentTimeMillis();
    }
    else {
      draw = false;
    }
  }


  class Branch
  {
    float startx, starty, endx, endy;
    float length;
    float degree;
    float nextx, nexty;
    float prevx, prevy;
    boolean next_flag = true;
    boolean draw_flag = true;

    public Branch(float sx, float sy, float ex, float ey, float sl, float sd)
    {
      startx = sx;
      starty = sy;
      endx = ex;
      endy = ey;
      length = sl;
      degree = sd;
      nextx = startx;
      nexty = starty;
      prevx = startx;
      prevy = starty;
      next_flag = true;
      draw_flag = true;
      Update();
      Render();
    }

    public void Update() {
      nextx += (endx - nextx) * 0.65;
      nexty += (endy - nexty) * 0.65;
      s_color = int (count / 10.0);
      s_weight = 2.0 / (count / 100 + 1);
      if (abs (nextx - endx) < 1.0 && abs (nexty - endy) < 1.0 && next_flag == true) {
        next_flag = false;
        draw_flag = false;
        nextx = endx;
        nexty = endy;
        int num = int (random (2, 4));
        for (int i = 0; i < num; i++) {
          float sx = endx;
          float sy = endy;
          float sl = random (random (5.0, 10.0), length * 0.99);
          float sd = random (-15.0, 15.0);
          float ex = sx + sl * cos (radians (sd + degree + offset));
          float ey = sy + sl * sin (radians (sd + degree + offset));
          branch.add(new Branch(sx, sy, ex, ey, sl, sd + degree));
        }
        count += 1;
      }
      if (branch.size() > 6000) {
        count = 0;
        s_color = 0;
        s_weight = 0;
        float screen = floor(random(2)) + 1;
        float sx = random (screenWidth);
        float sl = random (0.0, 180.0);
        float sy = screenHeight * screen - random((int) (screenHeight/5));
        branch = new ArrayList<Branch>();
        branch.add(new Branch(sx, sy, sx, sy - sl, sl, 0.0));
      }
    }

    public void Render() {
      if (draw_flag == true) {
        if (branch.size() < BRANCH_COLOR_CHANGE)
          stroke(noisy(100), noisy(69), noisy(19));//stroke (s_color);
        else
          stroke(noisy(20), noisy(100), noisy(40));
        strokeWeight (s_weight);
        line (prevx, prevy, nextx, nexty);
      }
      prevx = nextx;
      prevy = nexty;
    }
  }

  private int noisy(int val) {
    int minRange = 15;
    return (int) (val + random(min(-val/4, -minRange), max(val/4, minRange)));
  }

  void setGradient(int x, int y, float w, float h, color c1, color c2, int axis ) {

    noFill();

    if (axis == 1) {  // Top to bottom gradient
      for (int i = y; i <= y+h; i++) {
        float inter = map(i, y, y+h, 0, 1);
        color c = lerpColor(c1, c2, inter);
        stroke(c);
        line(x, i, x+w, i);
      }
    } else if (axis == 2) {  // Left to right gradient
      for (int i = x; i <= x+w; i++) {
        float inter = map(i, x, x+w, 0, 1);
        color c = lerpColor(c1, c2, inter);
        stroke(c);
        line(i, y, i, y+h);
      }
    }
  }
}
