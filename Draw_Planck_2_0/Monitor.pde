class Monitor extends Mode {
  color BG_COLOR2;

  int[] GRID_POS = {240, 200};
  int[] BAR_POS = {55, 500};
  int[] GRAPH_POS = {55, 700};
  int[] INTERPRET_POS = {200, 1500};
  int GRAPH_WIDTH = 1100;
  int GRAPH_HEIGHT = 50;

  void Monitor() {
    this.BG_COLOR2 = color(44, 125, 125);
  }

  void bg() {
    background(44, 125, 125 );
  }

  void display() {
    planche.showGrid(GRID_POS[0], GRID_POS[1]);
    planche.mur2(0, 400);
  }


  void update() {
  }

  void handleMidi() {
  }
}
