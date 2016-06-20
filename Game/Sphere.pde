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

  float speed() {
    return sqrt(pow(velocity.x, 2) + pow(velocity.y, 2));
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
      lastScore = -speed();
      score += lastScore;
    }
    if (location.y > side/2) {
      location.y = side/2;
      velocity.y = -velocity.y;
      lastScore = -speed();
      score += lastScore;
    }
    if (location.x < -side/2) {
      location.x = -side/2; 
      velocity.x = -velocity.x;
      lastScore = -speed();
      score += lastScore;
    }
    if (location.y < -side/2) {
      location.y = -side/2; 
      velocity.y = -velocity.y;
      lastScore = -speed();
      score += lastScore;
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
        lastScore = speed();
        score += lastScore;
      }
    }
  }
}