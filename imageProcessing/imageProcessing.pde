import processing.video.*;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.ArrayList;
Capture cam;

PImage img;
color white = color(255, 255, 255);
color black = color(0, 0, 0);
int threshmin = 100;
int threshmax = 135;
int bThresh = 150;
int numLines = 4;

boolean camera =false;
String imageName = "board1.jpg";

void settings() {
  size(960, 240);
}


void setup() {
  if (camera) {
    String[] cameras = Capture.list();
    if (cameras.length == 0) {
      println("There are no cameras available for capture.");
      exit();
    } else {
      println("Available cameras:");
      int camL = cameras.length;
      for (int i = 0; i < camL; i++) {
        println(cameras[i]);
      }
      cam = new Capture(this, cameras[5]);
      cam.start();
    }
  } else {
    noLoop();
  }
}
void draw() {
  if (camera) {
    if (cam.available() == true) {
      cam.read();
    }
    img = cam.get();
  } else {
    img = loadImage(imageName);
    img.resize(width/3, height);
  }




  PImage hueThresh = huethresh(img);
  PImage convolute = convolute(convolute(hueThresh));
  PImage brightThresh = intensitythresh(convolute, bThresh);


  PImage sobel = sobel(brightThresh);
  image(img, 0, 0);

  ArrayList<PVector> lines = hough(sobel, numLines);
  getIntersections(lines);

  image(sobel, 2* width/3, 0);
}

ArrayList<PVector> getIntersections(ArrayList<PVector> lines) {
  ArrayList<PVector> intersections = new ArrayList<PVector>();
  int linesSize = lines.size() - 1;
  for (int i = 0; i < linesSize; i++) {
    PVector line1 = lines.get(i);
    int linesSize2 = linesSize +1; 
    for (int j = i + 1; j < linesSize2; j++) {
      PVector line2 = lines.get(j);
      // compute the intersection and add it to 'intersections'
      // draw the intersection
      float d = cos(line2.y)*sin(line1.y) - cos(line1.y)*sin(line2.y);
      int x = (int) ((line2.x * sin(line1.y) - line1.x * sin(line2.y))/d);
      int y = (int) ((line1.x * cos(line2.y) - line2.x * cos(line1.y))/d);
      fill(255, 128, 0);
      if (x < img.width && x > 0 && y < img.height && y > 0) {
        ellipse(x, y, 10, 10);
      }
    }
  }
  return intersections;
}

PImage huethresh(PImage img) {
  PImage result = createImage(img.width, img.height, RGB);
  {
    loadPixels();
    int pixelSize = img.width * img.height; 
    for (int i = 0; i < pixelSize; i++) {
      float h = hue(img.pixels[i]);
      if (h < threshmax && h > threshmin) {
        result.pixels[i] = white;
      } else {
        result.pixels[i] = black;
      }
    }
    updatePixels();
  }
  return result;
}

PImage intensitythresh(PImage img, int bright) {
  PImage result = createImage(img.width, img.height, RGB);
  {
    loadPixels();
    int pixelSize = img.width * img.height;
    for (int i = 0; i < pixelSize; i++) {
      float h = brightness(img.pixels[i]);
      if (h > bright) {
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

  float weight = 0;
  float[][] kernel ={{3, 4, 3}, {4, 5, 4}, {3, 4, 3}};

  int iMax = kernel.length;
  int jMax = kernel[0].length;
  for (int i = 0; i < iMax; ++i) {
    for (int j = 0; j < jMax; ++j) {
      weight += kernel[i][j];
    }
  }


  int N = kernel.length;
  int widthLimit = img.width- N/2;
  int heightLimit = img.height- N/2;
  int pixel = 0;
  int numPixel = 0;
  int theP = 0;

  PImage result = createImage(img.width, img.height, ALPHA);
  {
    result.loadPixels();
    for (int x = N/2; x < widthLimit; ++x) {
      for (int y = N/2; y < heightLimit; ++y) {
        pixel = 0;
        numPixel = (y)*img.width + x;
        for (int i = 0; i < N; ++i) {
          for (int j = 0; j < N; ++j) {
            theP = (y+i - N/2)*img.width + x+j - N/2;

            pixel += brightness(img.pixels[theP]) * kernel[i][j];
          }
        }
        result.pixels[numPixel] =(int) color(pixel/weight);
      }
    }
    result.updatePixels();
  }
  return result;
}


PImage sobel(PImage img) {
  float[][] hKernel = { { 0, 1, 0 }, 
    { 0, 0, 0 }, 
    { 0, -1, 0 } };
  float[][] vKernel = { { 0, 0, 0 }, 
    { 1, 0, -1 }, 
    { 0, 0, 0 } };

  int N = hKernel.length;
  int widthLimit = img.width- N/2;
  int heightLimit = img.height- N/2;
  int numPixel = 0;
  int theP = 0;

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

  for (int x = N/2; x < widthLimit; ++x) {
    for (int y = N/2; y < heightLimit; ++y) {
      numPixel = (y)*img.width + x;
      sum_h = 0;
      sum_v = 0;
      for (int i = 0; i < N; ++i) {
        for (int j = 0; j < N; ++j) {
          theP = (y+i - N/2)*img.width + x+j - N/2;
          sum_h += brightness(img.pixels[theP]) * hKernel[i][j];
          sum_v += brightness(img.pixels[theP]) * vKernel[i][j];
        }
      }
      sum = sqrt(pow(sum_h, 2) + pow(sum_v, 2));
      buffer[numPixel] = sum;
      max = max(max, sum);
    }
  }
  result.loadPixels();

  for (int y = 1; y < heightLimit; y++) { // Skip top and bottom edges
    for (int x = 1; x < widthLimit; x++) { // Skip left and right
      if (buffer[y * img.width + x] > (int)(max * 0.3f)) { // 30% of the max
        result.pixels[y * img.width + x] = color(255);
      } else {
        result.pixels[y * img.width + x] = color(0);
      }
    }
  }
  result.updatePixels();
  return result;
}

ArrayList<PVector> hough(PImage edgeImg, int nLines) {

  float discretizationStepsPhi = 0.06f;
  float discretizationStepsR = 2.5f;

  // dimensions of the accumulator
  int phiDim = (int) (Math.PI / discretizationStepsPhi);
  int rDim = (int) (((edgeImg.width + edgeImg.height) * 2 + 1) / discretizationStepsR);

  // our accumulator (with a 1 pix margin around)
  int[] accumulator = new int[(phiDim + 2) * (rDim + 2)];

  // pre-compute the sin and cos values
  float[] tabSin = new float[phiDim];
  float[] tabCos = new float[phiDim];
  float ang = 0;
  float inverseR = 1.f / discretizationStepsR;

  for (int accPhi = 0; accPhi < phiDim; ang += discretizationStepsPhi, accPhi++) {
    // we can also pre-multiply by (1/discretizationStepsR) since we need it in the Hough loop
    tabSin[accPhi] = (float) (Math.sin(ang) * inverseR);
    tabCos[accPhi] = (float) (Math.cos(ang) * inverseR);
  }

  int heightLimit = edgeImg.height;
  int widthLimit = edgeImg.width;

  for (int y = 0; y < heightLimit; y++) {
    for (int x = 0; x < widthLimit; x++) {
      // Are we on an edge?
      if (brightness(edgeImg.pixels[y * edgeImg.width + x]) != 0) {
        for (int phi = 0; phi < phiDim; ++phi) {
          float r = (x * tabCos[phi] + y * tabSin[phi]);
          r += (rDim - 1)/2;
          accumulator[(phi+1) * (rDim+2) + (int)r + 1] +=1;
        }
      }
    }
  }



  ArrayList<Integer> bestCandidates = new ArrayList<Integer>();

  // size of the region we search for a local maximum
  int neighbourhood = 10;

  // only search around lines with more that this amount of votes
  // (to be adapted to your image)
  int minVotes = 50;
  int neighbourhoodLimit = neighbourhood/2+1;
  int neighbourIdx = 0;

  for (int accR = 0; accR < rDim; accR++) {
    for (int accPhi = 0; accPhi < phiDim; accPhi++) {

      // compute current index in the accumulator
      int idx = (accPhi + 1) * (rDim + 2) + accR + 1;

      if (accumulator[idx] > minVotes) {
        boolean bestCandidate=true;

        // iterate over the neighbourhood
        for (int dPhi=-neighbourhood/2; dPhi < neighbourhoodLimit; dPhi++) {
          // check we are not outside the image
          if ( accPhi+dPhi < 0 || accPhi+dPhi >= phiDim) continue;
          for (int dR=-neighbourhood/2; dR < neighbourhoodLimit; dR++) {
            // check we are not outside the image
            if (accR+dR < 0 || accR+dR >= rDim) continue;
            neighbourIdx = (accPhi + dPhi + 1) * (rDim + 2) + accR + dR + 1;

            if (accumulator[idx] < accumulator[neighbourIdx]) {
              // the current idx is not a local maximum!
              bestCandidate=false;
              break;
            }
          }
          if (!bestCandidate) break;
        }
        if (bestCandidate) {
          // the current idx *is* a local maximum
          bestCandidates.add(idx);
        }
      }
    }
  }

  Collections.sort(bestCandidates, new HoughComparator(accumulator));
  ArrayList<PVector> lines = new ArrayList<PVector>();

  int nBestLimit =  min(nLines, bestCandidates.size());

  for (int i = 0; i < nBestLimit; i++) {
    int idx = bestCandidates.get(i);

    // first, compute back the (r, phi) polar coordinates:
    int accPhi = (int) (idx / (rDim + 2)) - 1;
    int accR = idx - (accPhi + 1) * (rDim + 2) - 1;
    float r = (accR - (rDim - 1) * 0.5f) * discretizationStepsR;
    float phi = accPhi * discretizationStepsPhi;

    PVector v = new PVector(r, phi);
    lines.add(v);

    int x0 = 0;
    int y0 = (int) ((r / sin(phi)));
    int x1 = (int) (r / cos(phi));
    int y1 = 0;
    int x2 = edgeImg.width;
    int y2 = (int) (-cos(phi) / sin(phi) * x2 + r / sin(phi));
    int y3 = edgeImg.height;
    int x3 = (int) (-(y3 - r / sin(phi)) * (sin(phi) / cos(phi)));

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

  PImage houghImg = createImage(rDim + 2, phiDim + 2, ALPHA);
  int accLimit = accumulator.length;
  for (int i = 0; i < accLimit; i++) {
    houghImg.pixels[i] = color(min(255, accumulator[i]));
  }
  // You may want to resize the accumulator to make it easier to see:
  houghImg.resize(width/3, height);
  houghImg.updatePixels();
  image(houghImg, width/3, 0);

  return lines;
}