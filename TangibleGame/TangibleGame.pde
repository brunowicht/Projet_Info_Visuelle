import papaya.*;
import processing.video.*;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.ArrayList;
import java.util.Random;


Capture cam;
Movie movie;

PImage img;
int imgheight = 240;
int imgwidth = 320;
color white = color(255, 255, 255);
color black = color(0, 0, 0);
int threshmin = 85;
int threshmax = 125;
int bThresh = 150;
int numLines = 4;
float[][] gaussian = {
  {9, 12, 9}, 
  {12, 15, 12}, 
  {9, 12, 9}
};

boolean camera =true;
String imageName = "board3.jpg";


float depth = 800;
float side = 350;
float high = 10;
float angle_max = PI/3;
float angle_min = - angle_max;
float speed = 1.0;
float gravityConstant = 0.5;

int nObstacles;
boolean shiftMode;

Sphere sphere;
Box box;
ArrayList<Cylinder> obstacles;

PGraphics bg;
PGraphics topView;
PGraphics scoreboard;
PGraphics barChart;

float score;
float lastScore;
int time;
ArrayList<Float> scores;

HScrollbar hs;


void setup() {
  fullScreen(P3D);
  bg = createGraphics(width, height/4, P2D);
  topView = createGraphics(height/4 - 20, height/4 - 20, P2D);
  scoreboard = createGraphics(height/4 - 50, height/4 - 20, P2D);
  barChart = createGraphics(2*width/3, bg.height* 3/4, P2D);
  movie = new Movie(this, "testvideo.mp4");
  movie.loop();
  hs = new HScrollbar(width/3 -10, height - 30, 300, 20);

  sphere = new Sphere(10);
  box = new Box(side, high, PI/3);
  obstacles = new ArrayList<Cylinder>();
  shiftMode = false;
  nObstacles = 0;
  score = 0.0;
  lastScore = 0.0;
  time = 0;
  scores = new ArrayList<Float>();
  noStroke();
}
void draw() {
  background(255);


  drawBG();
  img = movie.get();
  
  img.loadPixels();
  img.resize(imgwidth, imgheight);

  colorFilters(img, 85, 125, 35, 210, 75, 255);


  convolute(img, gaussian);
  binaryFilter(img, 35);
  sobel(img);



  ArrayList<PVector> lines = hough(img, numLines);
  
  image(img, 0, 0);

  getIntersections(lines);


  QuadGraph quadgraph = new QuadGraph();
  quadgraph.build(lines, img.width, img.height);
  quadgraph.findCycles();
  List<int[]>quads  = quadgraph.cycles;

  TwoDThreeD projection = new TwoDThreeD(img.width, img.height);
  if (quads.size() >= 1) {
    PVector l1 = lines.get(quads.get(0)[0]);
    PVector l2 = lines.get(quads.get(0)[1]);
    PVector l3 = lines.get(quads.get(0)[2]);
    PVector l4 = lines.get(quads.get(0)[3]);
    List<PVector> points = new ArrayList<PVector>();
    points.add(intersection(l1, l2));
    points.add(intersection(l2, l3));
    points.add(intersection(l3, l4));
    points.add(intersection(l4, l1));
    sortCorners(points);

    PVector rotation = projection.get3DRotations(sortCorners(points));
    box.rx = min(max(angle_min, rotation.x), angle_max);
    box.rz = min(max(angle_min, rotation.z), angle_max);
   
  }





  image(bg, 0, height * 3/4);

  drawTopView();
  image(topView, 10, 10 + height * 3/4);

  drawScoreboard();
  image(scoreboard, height/4, 10 + height * 3/4);

  drawBarChart();
  image(barChart, width/3 -10, 10 + height * 3/4);

  hs.update();
  hs.display();

  if (! shiftMode) {
    ++time;
    scoreRegister();
    text("Rotation X: "+radToDeg(box.rx)+"\nRotation Z: "+radToDeg(box.rz)+"\nspeed: "+speed, width/2, 15);
    directionalLight(255, 220, 20, 0, 1, 0);
    ambientLight(120, 120, 120);
    fill(150);

    pushMatrix();
    box.display();
    for (Cylinder o : obstacles) {    
      pushMatrix();
      o.cylinder();
      popMatrix();
    }
    sphere.display();
    popMatrix();
  } else {

    fill(150);
    pushMatrix();
    translate(width/2, height/2);
    rect(-side/2, -side/2, side, side);
    text("SHIFT", side/2 + 10, side/2 -10);
    fill(50);
    ellipse(sphere.location.x, sphere.location.y, 2*sphere.radius, 2*sphere.radius);
    fill(200);
    for (Cylinder o : obstacles) {
      ellipse(o.abs, o.ord, 2*o.radius, 2*o.radius);
    }

    popMatrix();
  }
}

void scoreRegister() {
  if (time % 30 == 0) {
    scores.add(score);
  }
}

void movieEvent(Movie movie) {
  movie.read();
}

void mouseWheel(MouseEvent event) {
  speed = constrain(speed + 0.1 * event.getCount(), 0.2, 2);
}

void keyPressed() {
  if (keyCode == SHIFT) {
    shiftMode = true;
  }
}

void keyReleased() {
  if (keyCode == SHIFT) {
    shiftMode = false;
  }
}

void mouseClicked() {
  if (shiftMode) {
    float x = mouseX-width/2;
    float y = mouseY-height/2;
    if (x>=(-side/2) && x <= side/2 && y >=(-side/2) && y <= side/2) {
      obstacles.add(new Cylinder(20, 30, x, y));
      nObstacles +=1;
    }
  }
}
float radToDeg(float angle) {
  return angle * 180/PI;
}

void drawBG() {
  bg.beginDraw();
  bg.background(160, 120, 120);
  bg.endDraw();
}

void drawTopView() {
  topView.beginDraw();
  topView.background(250, 220, 15);
  topView.noStroke();
  topView.fill(150, 50, 50);
  float scale = (height/4 -20)/side;
  topView.ellipse(scale*sphere.location.x + topView.width/2, scale*sphere.location.y + topView.height/2, 2*sphere.radius*scale, 2*sphere.radius*scale);
  topView.fill(50, 150, 50);
  for (Cylinder o : obstacles) {
    topView.ellipse(o.abs*scale + topView.width/2, scale*o.ord + topView.height/2, scale*2*o.radius, scale*2*o.radius);
  }
  topView.endDraw();
}

void drawScoreboard() {
  scoreboard.beginDraw();
  scoreboard.background(180, 150, 150);
  scoreboard.fill(0);
  scoreboard.text("Total score:\n"+score, 15, 15);
  scoreboard.text("Velocity:\n"+sphere.speed(), 15, scoreboard.height/2 );
  scoreboard.text("Last Score:\n"+lastScore, 15, scoreboard.height-20);
  scoreboard.endDraw();
}

void drawBarChart() {
  int w = 5;
  float fact = hs.getPos();
  barChart.beginDraw();
  barChart.background(180, 150, 150);
  int nbSquare = 0;
  int x = 0;
  barChart.noStroke();
  barChart.fill(255, 255, 200);
  for (float s : scores) {
    nbSquare = floor(s/2);
    for (int i = 0; i < nbSquare; ++i) {
      barChart.rect((2 * w * fact + 2)*x+ 5, barChart.height -10 - 6*i, 2 * w * fact + 1, w );
    }
    ++x;
  }
  barChart.endDraw();
}