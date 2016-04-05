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