class MousePointer {
  int x, y;

  // Mouse doesn't have video
  Capture video = null;

  void update() {
    x = mouseX;
    y = mouseY;
  }

  void drawDragging() {
    cursor(HAND);
  }

  void drawPointing() {
    cursor(CROSS);
  }
}
