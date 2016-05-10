PImage img;
color white = color(255, 255, 255);
color black = color(0, 0, 0);
float thresh;
float thresh2;
//float[][] hKernel= {{0, 1, 0}, {0, 0, 0}, {0, -1, 0}};
//float[][] vKernel= {{0, 0, 0}, {1, 0, -1}, {0, 0, 0}};

HScrollbar thresholdBar;
HScrollbar thresholdBar2;


void settings() {
  size(800, 600);
}


void setup() {
  img = loadImage("board1.jpg");
  thresholdBar = new HScrollbar(0, 580, 800, 20);
  thresholdBar2 = new HScrollbar(0, 0, 800, 20);
  noLoop();
}
void draw() {
  

  PImage result;
  //result = thresh(img);
  result = convolute(img);
  image(result, 0, 0);
  /*
  thresholdBar2.display();
   thresholdBar2.update();
   thresholdBar.display();
   thresholdBar.update()*/
}

PImage thresh(PImage img) {
  thresh = 256 * thresholdBar.getPos();
  thresh2 = 256 * thresholdBar2.getPos();
  PImage result = createImage(width, height, RGB);
  {
    loadPixels();
    for (int i = 0; i < img.width * img.height; i++) {
      color c = img.pixels[i];
      float h = hue(c);
      if (h < thresh2 && h > thresh) {
        result.pixels[i] = c;
      } else {
        result.pixels[i] = black;
      }
    }
    updatePixels();
  }
  return result;
}



PImage convolute(PImage img) {
  float weight = 1;
  float[][] kernel ={{0, 1, 0}, {0, 0, 0}, {0, -1, 0}};
  // create a greyscale image (type: ALPHA) for output
  PImage result = createImage(img.width, img.height, ALPHA);
  int N = kernel.length;
  //
  for (int x = 0; x <= width-N; ++x) {
    for (int y = 0; y <= height-N; ++y) {
      int pixel = 0;
      int numPixel = (y+1)*width + x+1;
      for (int i = 0; i < N; ++i) {
        for (int j = 0; j < N; ++j) {
          int theP = (y+i)*width + x+j;

          pixel += img.pixels[theP] * kernel[i][j];
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


PImage sobel(PImage img) {
  float[][] hKernel = { { 0, 1, 0 }, 
    { 0, 0, 0 }, 
    { 0, -1, 0 } };
  float[][] vKernel = { { 0, 0, 0 }, 
    { 1, 0, -1 }, 
    { 0, 0, 0 } };
  PImage result = createImage(img.width, img.height, ALPHA);
  // clear the image
  for (int i = 0; i < img.width * img.height; i++) {
    result.pixels[i] = color(0);
  }
  float max=0;
  float[] buffer = new float[img.width * img.height];
  // *************************************
  // Implement here the double convolution
  // *************************************
  
  
  for (int y = 2; y < img.height - 2; y++) { // Skip top and bottom edges
    for (int x = 2; x < img.width - 2; x++) { // Skip left and right
      if (buffer[y * img.width + x] > (int)(max * 0.3f)) { // 30% of the max
        result.pixels[y * img.width + x] = color(255);
      } else {
        result.pixels[y * img.width + x] = color(0);
      }
    }
  }
  return result;
}

class HScrollbar {
  float barWidth; //Bar's width in pixels
  float barHeight; //Bar's height in pixels
  float xPosition; //Bar's x position in pixels
  float yPosition; //Bar's y position in pixels
  float sliderPosition, newSliderPosition; //Position of slider
  float sliderPositionMin, sliderPositionMax; //Max and min values of slider
  boolean mouseOver; //Is the mouse over the slider?
  boolean locked; //Is the mouse clicking and dragging the slider now?
  /**
   * @brief Creates a new horizontal scrollbar
   *
   * @param x The x position of the top left corner of the bar in pixels
   * @param y The y position of the top left corner of the bar in pixels
   * @param w The width of the bar in pixels
   * @param h The height of the bar in pixels
   */
  HScrollbar (float x, float y, float w, float h) {
    barWidth = w;
    barHeight = h;
    xPosition = x;
    yPosition = y;
    sliderPosition = xPosition + barWidth/2 - barHeight/2;
    newSliderPosition = sliderPosition;
    sliderPositionMin = xPosition;
    sliderPositionMax = xPosition + barWidth - barHeight;
  }

  /**
   * @brief Updates the state of the scrollbar according to the mouse movement
   */
  void update() {
    if (isMouseOver()) {
      mouseOver = true;
    } else {
      mouseOver = false;
    }
    if (mousePressed && mouseOver) {
      locked = true;
    }
    if (!mousePressed) {
      locked = false;
    }
    if (locked) {
      newSliderPosition = constrain(mouseX - barHeight/2, sliderPositionMin, sliderPositionMax);
    }
    if (abs(newSliderPosition - sliderPosition) > 1) {
      sliderPosition = sliderPosition + (newSliderPosition - sliderPosition);
    }
  }
  /**
   * @brief Clamps the value into the interval
   *
   * @param val The value to be clamped
   * @param minVal Smallest value possible
   * @param maxVal Largest value possible
   *
   * @return val clamped into the interval [minVal, maxVal]
   */
  float constrain(float val, float minVal, float maxVal) {
    return min(max(val, minVal), maxVal);
  }
  /**
   * @brief Gets whether the mouse is hovering the scrollbar
   *
   * @return Whether the mouse is hovering the scrollbar
   */
  boolean isMouseOver() {
    if (mouseX > xPosition && mouseX < xPosition+barWidth &&
      mouseY > yPosition && mouseY < yPosition+barHeight) {
      return true;
    } else {
      return false;
    }
  }
  /**
   * @brief Draws the scrollbar in its current state
   */
  void display() {
    noStroke();
    fill(204);
    rect(xPosition, yPosition, barWidth, barHeight);
    if (mouseOver || locked) {
      fill(0, 0, 0);
    } else {
      fill(102, 102, 102);
    }
    rect(sliderPosition, yPosition, barHeight, barHeight);
  }
  /**
   * @brief Gets the slider position
   *
   * @return The slider position in the interval [0,1]
   * corresponding to [leftmost position, rightmost position]
   */
  float getPos() {
    return (sliderPosition - xPosition)/(barWidth - barHeight);
  }
}