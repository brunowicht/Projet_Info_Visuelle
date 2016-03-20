float depth = 800;
float side = 500;
float high = 20;
float angle_max = PI/3;
float angle_min = - angle_max;
float speed = 1.0;
float rx = 0.0;
float rz = 0.0;
float gravityConstant = 0.1;
Sphere sphere;
Box box;

void settings() {
  size(800, 800, P3D);
}
void setup() {
  sphere = new Sphere(15);
  box = new Box(side, high);
  noStroke();
}
void draw() {
  camera(width/2, height/4, depth, width/2, height/2, 0, 0, 1, 0);
  directionalLight(50, 100, 125, 0, -1, 0);
  ambientLight(102, 102, 102);
  background(255);
  text("Rotation X: "+radToDeg(rx)+"   Rotation Z: "+radToDeg(rz)+"   speed : "+speed, 10+ width/6, height/5.5);
  box.display();
  sphere.display();
 
}

void mouseWheel(MouseEvent event) {
  speed = constrain(speed + 0.1 * event.getCount(), 0.2, 2);
}

float radToDeg(float angle) {
  return angle * 180/PI;
}