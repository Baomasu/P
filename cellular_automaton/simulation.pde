class Simulation {
  int stepSize;
  PVector screenSize;

  Simulation() {
    stepSize = 5;
    screenSize = new PVector(500, 500);
  }


  Simulation(int cellSize, int gridSizeWidth, int gridSizeHeight) {
    stepSize = cellSize;
    screenSize = new PVector(gridSizeWidth, gridSizeHeight);
  }


  void drawGrid(int posX, int posY, int state) {
    for (int x = 0; x <= screenSize.x-stepSize; x += stepSize) {
      for (int y = 0; y <= screenSize.y-stepSize; y += stepSize) {
        if (x/stepSize == posX && y/stepSize == posY) {
          pin(x,y,state);
        }
      }
    }   
  }

  void pin(int x, int y, int state) {
    push();
    if (state == 3) fill(255, 0, 0);
    else if (state == 2) fill(0, 255, 0);
    else if (state == 1) fill(0, 0, 255);
    else if (state == 0) fill(0, 0, 0);
    else fill(255, 255, 255);
    stroke(0);
    strokeWeight(0.1);
    rect(x, y, stepSize, stepSize);
    pop();
  }
}
