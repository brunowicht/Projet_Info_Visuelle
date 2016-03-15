class Sphere {
  PVector location;
  PVector velocity;
  PVector  gravity;
  PVector gravityForce;
  float radius = 10;

  Sphere() {
    location = new PVector(0, 0);
    velocity = new PVector(0, 0);
    gravity = new PVector(0, 0);
    gravityForce = new PVector(0, 0);
  }

  void update() {
    velocity.add(gravity);
    location.add(velocity);
  }

  void display() {
    translate(location.x, - 1.5 * radius, location.y);
    sphere(radius);
  }

  void gravity() {
    gravityForce.x = - sin(rz) * gravityConstant;
    gravityForce.y = sin(rx) * gravityConstant;
    gravity.x -= gravityForce.x;
    gravity.y -= gravityForce.y;
  }
  void checkEdges() {
    if (location.x > side/2 - radius) {
      location.x = side/2 - radius;
      velocity.x = velocity.x * -0.9;
    }
    if (location.y > side/2 - radius) {
      location.y = side/2 - radius;
      velocity.y = velocity.y * -0.9;
    }
    if (location.x < -side/2 + radius) {
      location.x = -side/2 + radius; 
      velocity.x = velocity.x * -0.9;
    }
    if (location.y < -side/2 + radius) {
      location.y = -side/2 + radius; 
      velocity.y = velocity.y * -0.9;
    }
  }
}