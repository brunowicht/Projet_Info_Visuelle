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
    
    rotateZ(rz);
    rotateX(rx);
  }
}