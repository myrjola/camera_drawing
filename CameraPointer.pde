import processing.video.*;

/**
 * A camera pointer making use of color tracking
 */
class CameraPointer {

  int x = 0, y = 0;

  Capture video;
  PImage frame;

  color chosenColor = color(255);

  CameraPointer(PApplet parent) {
    video = new Capture(parent, width, height);
    video.start();
    frame = createImage(video.width, video.height, ARGB);
  }

  void updateCamera()
  {
    if (video.available()) {
      video.read();
      video.loadPixels();
    }
  }

  void update() {
    updateCamera();

    frame.copy(video,
               0, 0, video.width, video.height,
               0, 0, video.width, video.height);
    frame.loadPixels();
    frame.filter(BLUR, 3);
    pushMatrix();
    scale(-1.0, 1.0);
    translate(-width, 0);
    image(frame, 0, 0);
    popMatrix();

    float targetHue = hue(chosenColor);
    float smallestHueDifference = 1;
    int index = 0;
    for (int pixelY = 0; pixelY < video.height; pixelY++) {
      for (int pixelX = 0; pixelX < video.width; pixelX++) {

        float pixelHue = hue(frame.pixels[index]);

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
    fill(chosenColor);
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
