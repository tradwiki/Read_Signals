class Monitor extends Mode {
  color BG_COLOR2;

  float[] GRID_POS = {screenWidth / 2, screenHeight * 2.5};
  int[] BAR_POS = {55, 500};
  int[] GRAPH_POS = {55, 700};
  int[] INTERPRET_POS = {200, 1500};
  int GRAPH_WIDTH = 1100;
  int GRAPH_HEIGHT = 50;
  PFont monitorFont;
  
  void Monitor() {
    this.name = "Monitor";
    this.BG_COLOR2 = color(44, 125, 125);
    this.monitorFont = createFont("Arial", 32);
  }

  void bg() {
    background(44, 125, 125);
  }

  void display() {
    planche.showGrid(GRID_POS[0], GRID_POS[1]);
    planche.mur(0, 0);
    textFont(createFont("Arial", 32));
    fill(255, 255, 255);
    text(planche.bpm, 10, screenHeight - 50);
  }

  void update() {
  }

}
