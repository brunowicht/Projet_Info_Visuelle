float depth = 800;
float side = 500;
float high = 20;
float angle_max = PI/3;
float angle_min = - angle_max;
float speed = 1.0;
float gravityConstant = 0.2;
Sphere sphere;
Box box;
ArrayList<Obstacle> obstacles;
int maxObstacles = 10;
int nObstacles;
boolean shiftMode;


void setup() {
  fullScreen(P3D);
  sphere = new Sphere(15);
  box = new Box(side, high, PI/3);
  obstacles = new ArrayList<Obstacle>();
  shiftMode = false;
  nObstacles = 0;
  noStroke();
}
void draw() {
  if (! shiftMode) {
    camera(width/2, height/4, depth, width/2, height/2, 0, 0, 1, 0);
    directionalLight(50, 100, 125, 0, -1, 0);
    ambientLight(102, 102, 102);
    background(255);
    text("Rotation X: "+radToDeg(box.rx)+"   Rotation Z: "+radToDeg(box.rz)+"   speed: "+speed, 100,100);
    pushMatrix();
    box.display();
    ambientLight(80, 20, 20);
    if (nObstacles > 0) {
      for (int i = 0; i< nObstacles; ++i) {    
        pushMatrix();
        obstacles.get(i).cylinder();
        popMatrix();
      }
    }
    ambientLight(20, 20, 80);
    sphere.display();
    popMatrix();
  } else {
    camera(width/2, height/2, depth, width/2, height/2, 0, 0, 1, 0);
    background(255);
    fill(150);
    pushMatrix();
    translate(width/2, height/2);
    rect(-side/2, -side/2, side, side);
    if (nObstacles > 0) {
      for (int i = 0; i< nObstacles; ++i) {
        fill(200);
        ellipse(obstacles.get(i).abs, obstacles.get(i).ord, 20, 20);
      }
    }
    popMatrix();
  }
}

void mouseWheel(MouseEvent event) {
  speed = constrain(speed + 0.1 * event.getCount(), 0.2, 2);
}

void keyPressed() {
  if (keyCode == SHIFT) {
    shiftMode = true;
  } else {
    shiftMode = false;
  }
}

void mouseClicked() {
  if (shiftMode) {
    if (nObstacles < maxObstacles) {
      float x = mouseX-width/2;
      float y = mouseY-height/2;
      if (x>=(-side/2) && x <= side/2 && y >=(-side/2) && y <= side/2) {
        obstacles.add(new Obstacle(20, 30, x, y));
        nObstacles +=1;
      }
    }
  }
}
float radToDeg(float angle) {
  return angle * 180/PI;
}