class Sphere {
  PVector location;
  PVector velocity;
  PVector gravityForce;
  PVector friction;
  PVector acceleration;

  float radius;
  float normalForce;
  float frictionMagnitude;
  float mu;

  Sphere(int r) {
    location = new PVector(0, 0);
    velocity = new PVector(0, 0);
    gravityForce = new PVector(0, 0);
    mu = 0.05;
    radius = r;
  }

  void update() {
    acceleration = gravityForce.get();
    acceleration.add(friction);
    velocity.add(acceleration);
    location.add(velocity);
  }

  void display() {
    checkEdges();
    friction();
    gravity();
    update();
    translate(location.x, -(radius + high/2), location.y);
    
    sphere(radius);
  }

  void gravity() {
    gravityForce.x = sin(box.rz) * gravityConstant;
    gravityForce.y = -sin(box.rx) * gravityConstant;
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
}