class MousePointer {
  int x, y;

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
