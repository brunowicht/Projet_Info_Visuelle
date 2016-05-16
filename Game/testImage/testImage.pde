import processing.video.*;
Capture cam;

PImage img;
color white = color(255, 255, 255);
color black = color(0, 0, 0);
float thresh;
float thresh2;


HScrollbar thresholdBar;
HScrollbar thresholdBar2;


void settings() {
  size(640, 480);
}


void setup() {
  /*String[] cameras = Capture.list();
   if (cameras.length == 0) {
   println("There are no cameras available for capture.");
   exit();
   } else {
   println("Available cameras:");
   for (int i = 0; i < cameras.length; i++) {
   println(cameras[i]);
   }
   cam = new Capture(this, cameras[5]);
   cam.start();
   }*/
  img = loadImage("board4.jpg");
  img.resize(width/2, height/2);
  thresholdBar = new HScrollbar(0, (height/2) - 12, 320, 12);
  thresholdBar2 = new HScrollbar(0, (height/2) - 30, 320, 12);
  //noLoop();
}
void draw() {
  /*if (cam.available() == true) {
   cam.read();
   }
   img = cam.get();*/
  image(img, 0, 0);
  PImage result;
  result = thresh(img);
  image(result, 0, height/2);
  PImage result2;
  result2 = sobel(result);
  image(result2, width/2, 0);
  hough(result2);

  thresholdBar2.display();
  thresholdBar2.update();
  thresholdBar.display();
  thresholdBar.update();
}

PImage thresh(PImage img) {
  thresh = 256 * thresholdBar.getPos();
  thresh2 = 256 * thresholdBar2.getPos();
  PImage result = createImage(img.width, img.height, RGB);
  {
    loadPixels();
    for (int i = 0; i < img.width * img.height; i++) {
      color c = img.pixels[i];
      float h = hue(c);
      if (h < thresh2 && h > thresh) {
        result.pixels[i] = white;
      } else {
        result.pixels[i] = black;
      }
    }
    updatePixels();
  }
  return result;
}



PImage convolute(PImage img) {
  float weight = 33;
  float[][] kernel ={{3, 4, 3}, {4, 5, 4}, {3, 4, 3}};
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

  int size = hKernel.length;
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
  float sum_h = 0.0;
  float sum_v = 0.0;
  float sum = 0.0;

  for (int y = 2; y < img.height - 2; y++) {
    for (int x = 2; x < img.width - 2; x++) {
      int p = y * img.width + x;
      sum_h = img.pixels[p- img.width] - img.pixels[p + img.width];
      sum_v = img.pixels[p-1] - img.pixels[p+1];
      sum = sqrt(pow(sum_h, 2) + pow(sum_v, 2));
      buffer[p] = sum;
      max = max(max, sum);
    }
  }

  for (int y = 2; y < img.height - 2; y++) { // Skip top and bottom edges
    for (int x = 2; x < img.width - 2; x++) { // Skip left and right
      if (buffer[y * img.width + x] > (int)(max * 0.1f)) { // 30% of the max
        result.pixels[y * img.width + x] = color(255);
      } else {
        result.pixels[y * img.width + x] = color(0);
      }
    }
  }
  return result;
}

void hough(PImage edgeImg) {
  float discretizationStepsPhi = 0.06f;
  float discretizationStepsR = 2.5f;
  // dimensions of the accumulator
  int phiDim = (int) (Math.PI / discretizationStepsPhi);
  int rDim = (int) (((edgeImg.width + edgeImg.height) * 2 + 1) / discretizationStepsR);
  // our accumulator (with a 1 pix margin around)
  int[] accumulator = new int[(phiDim + 2) * (rDim + 2)];
  // Fill the accumulator: on edge points (ie, white pixels of the edge
  // image), store all possible (r, phi) pairs describing lines going
  // through the point.
  for (int y = 0; y < edgeImg.height; y++) {
    for (int x = 0; x < edgeImg.width; x++) {
      // Are we on an edge?
      if (brightness(edgeImg.pixels[y * edgeImg.width + x]) != 0) {
        for (int phi = 0; phi < phiDim; ++phi) {
          int r = (int)((x * cos(phi * discretizationStepsPhi) + y * sin(phi * discretizationStepsPhi))/discretizationStepsR);
          if (r < 0) {
            r += (rDim - 1)/2;
          }
          accumulator[(phi+1) * (rDim+2) + r] +=1;
        }


        // ...determine here all the lines (r, phi) passing through
        // pixel (x,y), convert (r,phi) to coordinates in the
        // accumulator, and increment accordingly the accumulator.
        // Be careful: r may be negative, so you may want to center onto
        // the accumulator with something like: r += (rDim - 1) / 2
      }
    }
  }

  PImage houghImg = createImage(rDim + 2, phiDim + 2, ALPHA);
  for (int i = 0; i < accumulator.length; i++) {
    houghImg.pixels[i] = color(min(255, accumulator[i]));
  }
  // You may want to resize the accumulator to make it easier to see:
  houghImg.resize(width/2, height/2);
  houghImg.updatePixels();
  image(houghImg, width/2, height/2);


  for (int idx = 0; idx < accumulator.length; idx++) {
    if (accumulator[idx] > 200) {
      // first, compute back the (r, phi) polar coordinates:
      int accPhi = (int) (idx / (rDim + 2)) - 1;
      int accR = idx - (accPhi + 1) * (rDim + 2) - 1;
      float r = (accR - (rDim - 1) * 0.5f) * discretizationStepsR;
      float phi = accPhi * discretizationStepsPhi;
      // Cartesian equation of a line: y = ax + b
      // in polar, y = (-cos(phi)/sin(phi))x + (r/sin(phi))
      // => y = 0 : x = r / cos(phi)
      // => x = 0 : y = r / sin(phi)
      // compute the intersection of this line with the 4 borders of
      // the image
      int x0 = 0;
      int y0 = (int) ((r / sin(phi)));
      int x1 = (int) min((r / cos(phi)), edgeImg.width);
      int y1 = 0;
      int x2 = edgeImg.width;
      int y2 = (int) (min(-cos(phi) / sin(phi) * x2 + r / sin(phi), edgeImg.height));
      int y3 = edgeImg.height;
      int x3 = (int) (min(-(y3 - r / sin(phi)) * (sin(phi) / cos(phi)),edgeImg.width));
      // Finally, plot the lines
      stroke(204, 102, 0);
      if (y0 > 0) {
        if (x1 > 0)
          line(x0, y0, x1, y1);
        else if (y2 > 0)
          line(x0, y0, x2, y2);
        else
          line(x0, y0, x3, y3);
      } else {
        if (x1 > 0) {
          if (y2 > 0)
            line(x1, y1, x2, y2);
          else
            line(x1, y1, x3, y3);
        } else
          line(x2, y2, x3, y3);
      }
    }
  }
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