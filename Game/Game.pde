float depth = 800;
float side = 350;
float high = 10;
float angle_max = PI/3;
float angle_min = - angle_max;
float speed = 1.0;
float gravityConstant = 0.1;

int nObstacles;
boolean shiftMode;

Sphere sphere;
Box box;
ArrayList<Obstacle> obstacles;

PGraphics bg;
PGraphics topView;




void setup() {
  fullScreen(P3D);
  bg = createGraphics(width, height/4, P2D);
  topView = createGraphics(height/4 - 20, height/4 - 20, P2D);
  sphere = new Sphere(10);
  box = new Box(side, high, PI/3);
  obstacles = new ArrayList<Obstacle>();
  shiftMode = false;
  nObstacles = 0;
  noStroke();
}
void draw() {
  background(255);
  drawBG();
  image(bg, 0, height * 3/4);
  drawTopView();
  image(topView, 10, 10 + height * 3/4);
  if (! shiftMode) {
    text("Rotation X: "+radToDeg(box.rx)+"   Rotation Z: "+radToDeg(box.rz)+"   speed: "+speed, 0, 0);
    camera(width/2, height/2, depth, width/2, height/2, 0, 0, 1, 0);
    directionalLight(255, 220, 20, 0, 1, 0);
    ambientLight(120, 120, 120);
    fill(150);

    pushMatrix();
    box.display();
    for (Obstacle o : obstacles) {    
      pushMatrix();
      o.cylinder();
      popMatrix();
    }
    sphere.display();
    popMatrix();
  } else {
    camera(width/2, height/2, depth, width/2, height/2, 0, 0, 1, 0);

    fill(150);
    pushMatrix();
    translate(width/2, height/2);
    rect(-side/2, -side/2, side, side);
    text("SHIFT", side/2 + 10, side/2 -10);
    fill(50);
    ellipse(sphere.location.x, sphere.location.y, 2*sphere.radius, 2*sphere.radius);
    fill(200);
    for (Obstacle o : obstacles) {
      ellipse(o.abs, o.ord, 2*o.radius, 2*o.radius);
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
      obstacles.add(new Obstacle(20, 30, x, y));
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
  topView.background(50, 50, 150);
  topView.fill(150, 50, 50);
  float scale = (height/4 -20)/side;
  topView.ellipse(scale*sphere.location.x + topView.width/2, scale*sphere.location.y + topView.height/2, 2*sphere.radius*scale, 2*sphere.radius*scale);
  topView.fill(50,150,50);
  for(Obstacle o: obstacles){
    topView.ellipse(o.abs*scale + topView.width/2, scale*o.ord + topView.height/2, scale*2*o.radius, scale*2*o.radius);
  }
  topView.endDraw();
}


class Box {
  float side;
  float high;
  float rx;
  float rz;
  float angle_min;
  float angle_max;

  Box(float s, float h, float rot) {
    side = s;
    high = h;
    rx = 0;
    rz = 0;
    angle_min = -rot;
    angle_max = rot;
  }

  void display() {
    translate(width/2, height/2, 0);
    boxRotation();
    box(side, high, side);
  }

  void boxRotation() {
    if (mousePressed == true) {
      rx = rx + speed*(map(pmouseY - mouseY, 0, width, 0, 2*PI));
      rz = rz - speed*(map(pmouseX - mouseX, 0, height, 0, 2*PI));
    }
    rx = min(max(angle_min, rx), angle_max);
    rz = min(max(angle_min, rz), angle_max);
    rotateZ(rz);
    rotateX(rx);
  }
}


class Obstacle {
  float radius;
  float oHeight;
  int resolution;
  float abs;
  float ord;

  Obstacle(float b, float h, float x, float y) {
    radius = b;
    oHeight = h;
    resolution = 100;
    abs = x;
    ord = y;
  }

  void cylinder() {
    PShape openCylinder = new PShape();
    float angle;
    float[] x = new float[resolution + 1]; 
    float[] y = new float[resolution + 1];
    //get the x and y position on a circle for all the sides 
    for (int i = 0; i < x.length; i++) { 
      angle = (TWO_PI / resolution) * i; 
      x[i] = sin(angle) * radius; 
      y[i] = cos(angle) * radius;
    }
    translate(abs, -high/2, ord);
    rotateX(PI/2);

    openCylinder = createShape();

    openCylinder.beginShape(TRIANGLES);
    for (int i = 0; i < x.length-1; i++) { 
      openCylinder.vertex(0, 0, 0); 
      openCylinder.vertex(x[i], y[i], 0);
      openCylinder.vertex(x[i+1], y[i+1], 0);
    } 
    for (int i = 0; i < x.length-1; i++) { 
      openCylinder.vertex(0, 0, oHeight); 
      openCylinder.vertex(x[i], y[i], oHeight);
      openCylinder.vertex(x[i+1], y[i+1], oHeight);
    } 

    openCylinder.endShape();

    openCylinder.beginShape(QUAD_STRIP); //draw the border of the cylinder 
    for (int i = 0; i < x.length; i++) { 
      openCylinder.vertex(x[i], y[i], 0); 
      openCylinder.vertex(x[i], y[i], oHeight);
    } 
    openCylinder.endShape();
    shape(openCylinder);
  }
}


class Sphere {
  PVector location;
  PVector velocity;
  PVector friction;
  PVector acceleration;

  float radius;
  float normalForce;
  float frictionMagnitude;
  float mu;

  Sphere(int r) {
    location = new PVector(0, 0);
    velocity = new PVector(0, 0);
    acceleration = new PVector(0, 0);
    mu = 0.03;
    radius = r;
  }

  void update() {
    acceleration.add(friction);
    velocity.add(acceleration);
    location.add(velocity);
  }

  void display() {
    checkEdges();
    collide();
    friction();
    gravity();
    update();
    translate(location.x, -(radius + high/2), location.y);

    sphere(radius);
  }

  void gravity() {
    acceleration.x = sin(box.rz) * gravityConstant;
    acceleration.y = -sin(box.rx) * gravityConstant;
  }

  void friction() {
    normalForce = sqrt((pow(cos(box.rz), 2) + pow(cos(box.rx), 2))/2);
    frictionMagnitude = normalForce * mu;
    friction = velocity.get();
    friction.mult(-1);
    friction.normalize();
    friction.mult(frictionMagnitude);
  }

  void checkEdges() {
    if (location.x > side/2) {
      location.x = side/2;
      velocity.x = -velocity.x;
    }
    if (location.y > side/2) {
      location.y = side/2;
      velocity.y = -velocity.y;
    }
    if (location.x < -side/2) {
      location.x = -side/2; 
      velocity.x = -velocity.x;
    }
    if (location.y < -side/2) {
      location.y = -side/2; 
      velocity.y = -velocity.y;
    }
  }

  float distanceTo(Obstacle o) {
    return sqrt(pow(location.x - o.abs, 2) + pow(location.y - o.ord, 2))  - radius - o.radius;
  }

  void collide() {
    for (Obstacle o : obstacles) {
      if (distanceTo(o) <= 0) {
        PVector n = new PVector(location.x-o.abs, location.y-o.ord);
        velocity = velocity.sub(n.normalize().mult(2 * velocity.dot(n.normalize())));
        location.x = o.abs - n.normalize().x * (radius + o.radius);
        location.y = o.ord - n.normalize().y * (radius + o.radius);
      }
    }
  }
}