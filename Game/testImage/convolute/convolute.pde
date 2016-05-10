PImage img;

void settings() {
  size(800, 600);
}

void setup() {
  img = loadImage("board1.jpg");
  noLoop();
}

void draw() {
  PImage result = convolute(img);

  image(result, 0, 0);
}

PImage convolute(PImage img) {
  float[][] kernel = { { 0, 0, 0 }, 
    { 0, 2, 0 }, 
    { 0, 0, 0 }};
  float weight = 1.f;
  // create a greyscale image (type: ALPHA) for output
  PImage result = createImage(img.width, img.height, ALPHA);
  int N = 3;
  //
  for(int x = 0; x <= width-N; ++x){
    for(int y = 0; y <= height-N; ++y){
      int pixel = 0;
      int numPixel = (x+1)*width + y+1;
      for(int i = 0; i < N; ++i){
        for(int j = 0; j < N; ++j){
          
          pixel += img.pixels[numPixel] * kernel[i][j];
        }
      }
      result.pixels[numPixel] =(int) (pixel/weight);
    }
  }
          
  // for each (x,y) pixel in the image:
  // - multiply intensities for pixels in the range
  // (x - N/2, y - N/2) to (x + N/2, y + N/2) by the
  // corresponding weights in the kernel matrix
  // - sum all these intensities and divide it by the weight
  // - set result.pixels[y * img.width + x] to this value
  return result;
}