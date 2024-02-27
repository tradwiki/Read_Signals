import processing.svg.*;
PShape logo;
PImage bg_image1, bg_image2, bg_floor;

class Menu extends Mode {
  int[] GRID_POS = {screenWidth / 2, + screenHeight * 2 + 200};
  int currFrame;
  int currSelect, selectCount;
  PFont menuFont;
  color logoColor;
  Menu() {
    this.name = "Menu";
    menuFont = createFont("Arial", 32);
    BG_COLOR = color(123);
    logo = loadShape("logo_vdj.svg");
    bg_image1 = loadImage("bg_1.png");
    bg_image2 = loadImage("bg_2.png");
    bg_floor = loadImage("bg_3.png");
    bg_floor.resize(screenWidth, screenHeight);
    currFrame = 0;
    logoColor = color(255, 255, 255);

    currSelect = -1;
    selectCount = 0;
  }

  void bg() {
    background(BG_COLOR);
  }

  void bg_animation() {
    rectMode(CORNER);
    image(bg_floor, 0, screenHeight * 2);
    logo.disableStyle();
    noStroke();
    fill(logoColor);
    shape(logo, screenWidth / 2 - 150, screenHeight / 2 - 150, 300, 300);
    //screen 1
    image(bg_image1, 0, 0, screenWidth, screenHeight, 0, currFrame, screenWidth, screenHeight + currFrame);
    //screen 2
    image(bg_image2, 0, screenHeight, screenWidth, screenHeight, 0, currFrame, screenWidth, screenHeight + currFrame);
    if ( (screenHeight + currFrame) > bg_image1.height) {
      //screen 1
      image(bg_image1, 0, 2000 -  currFrame, screenWidth, (screenHeight + currFrame) % 2000, 0, 0, screenWidth, (screenHeight + currFrame) % 2000);
      //screen 2
      image(bg_image2, 0, screenHeight + 2000 -  currFrame, screenWidth, (screenHeight + currFrame) % 2000, 0, 0, screenWidth, (screenHeight + currFrame) % 2000);
    }
    currFrame = (currFrame + 1) % bg_image1.height;
    shape(logo, screenWidth / 2 - 150, screenHeight / 2 - 150, 300, 300);
  }

  void display() {
    bg_animation();

    planche.showGrid(GRID_POS[0], GRID_POS[1]);

    if (nextMode.equals("")) {
      showModes();
    } else {
      outro();
    }
  }

  void outro() {
    if (outroCount < 255) {
      outroCount+=5;
      fill(0, 0, 0, outroCount);
      rect(screenWidth / 2, screenHeight * 1.5, screenWidth, screenHeight * 3);
      textAlign(CENTER);
      textSize(36);
      fill(255);
      text(nextMode, screenWidth / 2, screenHeight * 1.5);
    } else {
      changeMode = true;
    }
  }

  void showModes() {
    textFont(menuFont);
    fill(100, 100, 100, 100);
    if (currSelect == 0) {
      fill(255, 123, 0, 50 + selectCount);
    }
    rect(150, screenHeight + 100, 200, 100, 28);
    textAlign(CENTER);
    fill(255, 255, 255, 255);
    text("Moniteur", 150, screenHeight + 110);

    fill(100, 100, 100, 100);
    if (currSelect == 1) {
      fill(255, 123, 0, 50 + selectCount);
    }
    rect(screenWidth - 150, screenHeight + 100, 200, 100, 28);
    textAlign(CENTER);
    fill(255, 255, 255, 255);
    text("Raindrop", screenWidth - 150, screenHeight + 110);

    fill(100, 100, 100, 50);
    if (currSelect == 2) {
      fill(255, 123, 0, 50 + selectCount);
    }
    rect(150, 2 * screenHeight - 100, 200, 100, 28);
    textAlign(CENTER);
    fill(255, 255, 255, 255);
    text("Reboisons", 150, 2 * screenHeight - 90);

    fill(100, 100, 100, 50);
    if (currSelect == 3) {
      fill(255, 123, 0, 50 + selectCount);
    }
    rect(screenWidth - 150, 2 * screenHeight - 100, 200, 100, 28);
    textAlign(CENTER);
    fill(255, 255, 255, 255);
    text("Mondrian", screenWidth - 150, 2 * screenHeight - 90);
  }


  void update() {
    if (selectCount > 100) {
      logoColor = color(160, 32, 240);
      switch (currSelect) {
      case 0:
        nextMode = "Moniteur";
        break;
      case 1:
        nextMode = "Raindrop";
        break;
      case 2:
        nextMode = "Reboisons";
        break;
      case 3:
        nextMode = "Mondrian";
        break;
      }
    }
  }

  void handleOSC(OscMessage theOscMessage) {
    if (theOscMessage.checkAddrPattern("/FSR/PG")) {
      if (currSelect == 0) {
        selectCount++;
        logoColor = color(255, 255, 123, 0);
      } else {
        selectCount = 0;
        logoColor = color(255, 255, 255);
      }
      currSelect = 0;
    }
    if (theOscMessage.checkAddrPattern("/FSR/PD")) {
      if (currSelect == 1) {
        selectCount++;
        logoColor = color(255, 255, 123, 0);
      } else {
        selectCount = 0;
        logoColor = color(255, 255, 255);
      }
      currSelect = 1;
    }
    if (theOscMessage.checkAddrPattern("/FSR/AG")) {
      if (currSelect == 2) {
        selectCount++;
        logoColor = color(255, 255, 123, 0);
      } else {
        selectCount = 0;
        logoColor = color(255, 255, 255);
      }
      currSelect = 2;
    }
    if (theOscMessage.checkAddrPattern("/FSR/AD")) {
      if (currSelect == 3) {
        selectCount++;
        logoColor = color(255, 255, 123, 0);
      } else {
        selectCount = 0;
        logoColor = color(255, 255, 255);
      }
      currSelect = 3;
    }
  }
}
