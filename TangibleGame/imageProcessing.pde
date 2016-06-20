
PVector intersection(PVector line1, PVector line2) {
  float d = cos(line2.y)*sin(line1.y) - cos(line1.y)*sin(line2.y);
  int x = (int) ((line2.x * sin(line1.y) - line1.x * sin(line2.y))/d);
  int y = (int) ((line1.x * cos(line2.y) - line2.x * cos(line1.y))/d);

  return new PVector(x, y);
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
      intersections.add(new PVector(x, y));
      fill(255, 128, 0);
      if (x < img.width && x > 0 && y < img.height && y > 0) {
        ellipse(x, y, 10, 10);
      }
    }
  }
  return intersections;
}

void colorFilters(PImage img, int hueMin, int hueMax, int brightnessMin, int brightnessMax, int saturationMin, int saturationMax) {
  for (int i = 0; i != img.pixels.length; ++i) {
    int pixel = img.pixels[i];

    // Filter hue
    float hue = hue(pixel);
    if (hue < hueMin || hue > hueMax) {
      img.pixels[i] = black;
      continue;
    }

    // Filter brightness
    float brightness = brightness(pixel);
    if (brightness < brightnessMin || brightness > brightnessMax) {
      img.pixels[i] = black;
      continue;
    }

    // Filter saturation
    float saturation = saturation(pixel);
    if (saturation < saturationMin || saturation > saturationMax) {
      img.pixels[i] = black;
      continue;
    }
  }
}

void convolute(PImage img, float[][] kernel) {
  int[] result = new int[img.pixels.length];
  for (int x = 0; x != img.width; ++x) {
    for (int y = 0; y != img.height; ++y) {
      float r = 0;
      float g = 0;
      float b = 0;
      float w = 0;
      
      for (int i = 0; i != kernel.length; ++i) {
        for (int j = 0; j != kernel[i].length; ++j) {
          int pixel = img.get(x + i - (kernel.length/2), y + j - (kernel.length/2));
          r += red(pixel) * kernel[i][j];
          g += green(pixel) * kernel[i][j];
          b += blue(pixel) * kernel[i][j];
          w += kernel[i][j];
        }
      }
      
      if (w == 0) {
        w = 1;
      }
      
      result[x + y * img.width] = color(r/w, g/w, b/w);
    }
  }
  img.pixels = result;
}

void binaryFilter(PImage img, int threshold) {
  for (int i = 0; i < img.pixels.length; ++i) {
    if (brightness(img.pixels[i]) >= threshold) {
      img.pixels[i] = white;
    } else {
      img.pixels[i] = black;
    }
  }
}

void sobel(PImage img) {
  float[][] hKernel = {
    { 0, 1, 0 }, 
    { 0, 0, 0 }, 
    { 0, -1, 0 }
  };

  float[][] vKernel = { 
    { 0, 0, 0 }, 
    { 1, 0, -1 }, 
    { 0, 0, 0 }
  };
  
  int[] result = new int[img.pixels.length];
  // clear the image
  for (int i = 0; i < img.pixels.length; i++) {
    result[i] = black;
  }
  
  float max=0.f;
  float[] buffer = new float[img.width * img.height];

  //Convolution
  for ( int x = 1; x < img.width - 1; x++) {
    for (int y = 1; y < img.height - 1; y++) {
      float sum_h = 0.f;
      float sum_v = 0.f;

      for (int i=0; i<3; i++) {
        for (int j=0; j<3; j++) {
          sum_h = sum_h + hKernel[i][j] * img.get(x-1+i, y-1+j);
          sum_v = sum_v + vKernel[i][j] * img.get(x-1+i, y-1+j);
        }
      }

      float sum = pow(sum_h, 2) + pow(sum_v, 2);
      if (max<sum) max = sum;

      buffer[y*img.width + x] = sum;

      if (buffer[y * img.width + x] > (int)(max * 0.3f)) {
        result[y * img.width + x] = color(255);
      } else {
        result[y * img.width + x] = color(0);
      }
    }
  }
  img.pixels = result;
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
  }

  return lines;
}