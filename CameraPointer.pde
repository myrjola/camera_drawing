import processing.video.*;

Capture video;

class CameraPointer {

  int x = 0, y = 0;

  CameraPointer(PApplet parent) {
    video = new Capture(parent, width, height);
    video.start();
  }

  void update() {
    if (video.available()) {
      video.read();
      float brightestValue = 0; // Brightness of the brightest video pixel
      // Search for the brightest pixel: For each row of pixels in the video image and
      // for each pixel in the yth row, compute each pixel's index in the video
      video.loadPixels();
      int index = 0;
      for (int pixelY = 0; pixelY < video.height; pixelY++) {
        for (int pixelX = 0; pixelX < video.width; pixelX++) {
          // Get the color stored in the pixel
          color pixelValue = video.pixels[index];
          // Determine the brightness of the pixel. Better to use the value closest to white.
          // TODO: Maybe even regional weighting to favor whiter areas.
          float pixelBrightness = red(pixelValue) + green(pixelValue) + blue(pixelValue);
          // If that value is brighter than any previous, then store the
          // brightness of that pixel, as well as its (pixelX,pixelY) location
          if (pixelBrightness > brightestValue) {
            brightestValue = pixelBrightness;
            y = pixelY;
            x = pixelX;
          }
          index++;
        }
      }
      // Draw a circle at the cursor;
      fill(255, 204, 0, 128);
      pushMatrix();
      translate(x, y);
      ellipse(0, 0, 10, 10);
      popMatrix();
    }
  }

  void drawDragging() {
  }

  void drawPointing() {
  }
}
