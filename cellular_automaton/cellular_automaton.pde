Matrics matrics;
Table table;
int scene = 6;
int toggle = 1;
int log = 1;


void setup()
{
  size(1000, 1000);
  frameRate(30);
  table = loadTable("csv/gb_toad.csv", "header");
  matrics = new Matrics(table, 10, 1000, 1000);
  matrics.readTable();
}

void draw() {
  background(0);
  if (scene == 0 || scene == 999) {
    if (scene == 0) {
      setup();
      log = 1;
      scene = 999;
    }
    matrics.drawTable();
  } else if (scene == 1|| scene == 111) {
    if (scene == 1 && log == 1) {
      setup();
      scene = 111;
    }else if(scene == 1 && log == 0)
    {
      setup();
      matrics.randomize();
      scene = 111;
    }
    //matrics.drawGen();
    matrics.drawTable();
  } else if (scene == 2 || scene == 222) {
    if (scene == 2) {
      toggle = toggle*(1-2);
      scene = 222;
    }
    if (toggle == -1) {
      matrics.drawGen();
      matrics.drawTable();
    } else if (toggle == 1)matrics.drawTable();
  } else if (scene == 3 || scene == 333) {
    if (scene == 3) {
      matrics.drawGen();
      scene = 333;
    }
    matrics.drawTable();
  } else if (scene == 4 || scene == 444) {
    if (scene == 4) {
      setup();
      matrics.randomize();
      log = 0;
      scene = 444;
    }
    matrics.drawGen();
    matrics.drawTable();
  } else if (scene == 5 || scene == 555) {
    if(scene == 5){
    saveTable(matrics.screenshot(), "csv/save.csv");
    scene = 555;
    }
    matrics.drawTable();
  } else if (scene == 6) {
    drawMenu(60, 60);
  }
}

void keyPressed() {
  if (key == 'L' || key == 'l') {
    toggle = 1;
    scene = 0;
  } else if (keyCode == LEFT) {
    toggle = 1;
    scene = 1;
  } else if (key == ' ') {
    scene = 2;
  } else if (keyCode == RIGHT) {
    toggle = 1;
    scene = 3;
  } else if (key == 'R' || key == 'r') {
    toggle = -1;
    scene = 4;
  } else if (key == 'S' || key == 's') {
    toggle = -1;
    scene = 5;
  } else if (key == 'H' || key == 'h') {
    toggle = -1;
    scene = 6;
  }
}

void drawMenu(int x, int y) {
  push();
  translate(x, y);
  textSize(20);
  fill(255);
  text("Press 'l' te load from csv", 0, 0);
  translate(0, y/1.8);
  text("Press arrow left to restart from initial state", 0, 0);
  translate(0, y/1.8);
  text("Press space bar to pause simulation", 0, 0);
  translate(0, y/1.8);
  text("Press arrow right for step by step simulation", 0, 0);
  translate(0, y/1.8);
  text("Press 'r' to randomize", 0, 0);
  translate(0, y/1.8);
  text("Press 's' save to csv", 0, 0);
  translate(0, y/1.8);
  text("Press 'h' to return to this help screen", 0, 0);
  pop();
}
