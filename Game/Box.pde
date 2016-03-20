class Box {
  float side;
  float high;

  Box(float s, float h) {
    side = s;
    high = h;
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