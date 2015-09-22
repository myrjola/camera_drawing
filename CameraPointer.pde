import processing.video.*;

/**
 * A camera pointer making use of color tracking
 */
class CameraPointer {

  float lastX = 0, lastY = 0;
  float x = 0, y = 0;

  Capture video;
  float[][] hueMatrix;

  color trackedColor = color(255);

  CameraPointer(PApplet parent) {
    video = new Capture(parent, width, height);
    video.start();
    hueMatrix = new float[height][width];
  }

  boolean updateCamera(boolean captureToScreen)
  {
    boolean videoWasAvailable = video.available();

    if (videoWasAvailable) {
      video.read();
      video.loadPixels();
    }

    if (captureToScreen) {
      pushMatrix();
      scale(-1.0, 1.0);
      translate(-width, 0);
      image(video, 0, 0);
      popMatrix();
    }

    return videoWasAvailable;
  }

  void update(boolean debugMode) {
    updateCamera(debugMode);
    float targetHue = hue(trackedColor);
    float smallestHueDifference = MAX_FLOAT;
    int index = 0;

    // First pass: copy over hue values to hueMatrix.
    for (int pixelY = 0; pixelY < video.height; pixelY++) {
      for (int pixelX = 0; pixelX < video.width; pixelX++) {
        hueMatrix[pixelY][pixelX] = hue(video.pixels[index]);
        index++;
      }
    }

    // Second pass: find the pixel where the difference is minimized taking into
    // account other pixels close by.
    int samplingRadius = 32;

    for (int pixelY = samplingRadius; pixelY < (video.height - samplingRadius); pixelY++) {
      for (int pixelX = samplingRadius; pixelX < (video.width - samplingRadius); pixelX++) {

        float pixelHue = hueMatrix[pixelY][pixelX];

        float neighbor1Hue = hueMatrix[pixelY - samplingRadius][pixelX];
        float neighbor2Hue = hueMatrix[pixelY + samplingRadius][pixelX];
        float neighbor3Hue = hueMatrix[pixelY][pixelX - samplingRadius];
        float neighbor4Hue = hueMatrix[pixelY][pixelX + samplingRadius];
        float neighbor5Hue = hueMatrix[pixelY - samplingRadius/2][pixelX];
        float neighbor6Hue = hueMatrix[pixelY + samplingRadius/2][pixelX];
        float neighbor7Hue = hueMatrix[pixelY][pixelX - samplingRadius/2];
        float neighbor8Hue = hueMatrix[pixelY][pixelX + samplingRadius/2];

        // We are trying to minimize the squares of the difference
        float hueDifference  = sq(abs(targetHue - pixelHue));
        float hueDifference1 = sq(abs(targetHue - neighbor1Hue));
        float hueDifference2 = sq(abs(targetHue - neighbor2Hue));
        float hueDifference3 = sq(abs(targetHue - neighbor3Hue));
        float hueDifference4 = sq(abs(targetHue - neighbor4Hue));
        float hueDifference5 = sq(abs(targetHue - neighbor5Hue));
        float hueDifference6 = sq(abs(targetHue - neighbor6Hue));
        float hueDifference7 = sq(abs(targetHue - neighbor7Hue));
        float hueDifference8 = sq(abs(targetHue - neighbor8Hue));

        float totalDifference = hueDifference +
          (hueDifference1 + hueDifference2 + hueDifference3 + hueDifference4) / 5 +
          (hueDifference5 + hueDifference6 + hueDifference7 + hueDifference8) / 2;

        if (totalDifference < smallestHueDifference) {
          smallestHueDifference = totalDifference;
          y = pixelY;
          // We want to mirror the x-axis for more natural motions.
          x = width - pixelX;
        }
        index++;
      }
    }
    // After this we want to smoothen out the movement.
    float deltaX = x - lastX;
    float deltaY = y - lastY;

    x = lastX + deltaX / 50.0;
    y = lastY + deltaY / 50.0;

    lastX = x;
    lastY = y;

    // Draw a circle at the cursor;
    fill(trackedColor);
    pushMatrix();
    translate(x, y);
    ellipse(0, 0, 10, 10);
    popMatrix();
  }

  void drawDragging() {
  }

  void drawPointing() {
  }
}
