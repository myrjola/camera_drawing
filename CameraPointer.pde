import processing.video.*;

/**
 * A camera pointer making use of color tracking
 */
class CameraPointer {

  int x = 0, y = 0;

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
    float smallestHueDifference = 255;
    int index = 0;

    // First pass: copy over hue values to hueMatrix.
    for (int pixelY = 0; pixelY < video.height; pixelY++) {
      for (int pixelX = 0; pixelX < video.width; pixelX++) {
        hueMatrix[pixelY][pixelX] = hue(video.pixels[index]);
        index++;
      }
    }

    // Second pass: find the pixel where the difference is minimized taking into
    // account neighboring pixels.
    int samplingRadius = 32;

    for (int pixelY = 32; pixelY < (video.height - samplingRadius); pixelY++) {
      for (int pixelX = 32; pixelX < (video.width - samplingRadius); pixelX++) {

        float pixelHue = hueMatrix[pixelY][pixelX];

        float hueDifference = abs(targetHue - pixelHue);

        if (hueDifference < smallestHueDifference) {
          smallestHueDifference = hueDifference;
          y = pixelY;
          // We want to mirror the x-axis for more natural motions.
          x = width - pixelX;
        }
        index++;
      }
    }
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
