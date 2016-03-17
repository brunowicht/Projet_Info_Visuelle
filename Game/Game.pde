float depth = 800;
float side = 500;
float high = 20;
float angle_max = PI/3;
float angle_min = - angle_max;
float speed = 1.0;
float rx = 0.0;
float rz = 0.0;
float gravityConstant = 0.02;
Sphere sphere;

void settings() {
  size(800, 800, P3D);
}
void setup() {
  sphere = new Sphere(15);
  noStroke();
}
void draw() {
  camera(width/2, height/2, depth, width/2, height/2, 0, 0, 1, 0);
  directionalLight(50, 100, 125, 0, -1, 0);
  ambientLight(102, 102, 102);
  background(255);
  text("Rotation X: "+radToDeg(rx)+"   Rotation Z: "+radToDeg(rz)+"   speed : "+speed, 10+ width/6, height/5.5);
  translate(width/2, height/2, 0);
  boxRotation();
  box(side, high, side);
  sphere.display();
 
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

void mouseWheel(MouseEvent event) {
  speed = constrain(speed + 0.1 * event.getCount(), 0.2, 2);
}

float radToDeg(float angle) {
  return angle * 180/PI;
}