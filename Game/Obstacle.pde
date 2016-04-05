class Obstacle {
  float oBaseSize;
  float oHeight;
  int resolution;
  float abs;
  float ord;

  Obstacle(float b, float h, float x, float y) {
    oBaseSize = b;
    oHeight = h;
    resolution = 200;
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
      x[i] = sin(angle) * oBaseSize; 
      y[i] = cos(angle) * oBaseSize;
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