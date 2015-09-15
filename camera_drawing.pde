
ArrayList<PaintShape> particles = new ArrayList<PaintShape>();

float lastCursorX, lastCursorY, deltaX, deltaY;

boolean controlDown, shiftDown, altDown;

PaintShape lockedShape = null;

void setup()
{
  size(640, 360, P2D);
}

void draw()
{
  float pointerX = mouseX;
  float pointerY = mouseY;
  deltaX = pointerX - lastCursorX;
  deltaY = pointerY - lastCursorY;
  lastCursorX = pointerX;
  lastCursorY = pointerY;
  background(color(255));

  if (!controlDown && !shiftDown && !altDown) {
    lockedShape = null;
  }
  for (int i=0; i < particles.size(); i++)
  {
    particles.get(i).draw(mouseX, mouseY);
  }
  // Draw a rotation arm
  if (controlDown && lockedShape != null) {
    line(lockedShape.getCenterX(), lockedShape.getCenterY(), pointerX, pointerY);
  }
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == CONTROL) {
      controlDown = true;
    } else if (keyCode == ALT) {
      altDown = true;
    } else if (keyCode == SHIFT) {
      shiftDown = true;
    }
  } else if (key == 'e') {
    particles.add(new PaintShape(mouseX, mouseY, ELLIPSE));
  } else if (key == 'r') {
    particles.add(new PaintShape(mouseX, mouseY, RECT));
  }
}

void keyReleased() {
  if (key == CODED) {
    if (keyCode == CONTROL) {
      controlDown = false;
    } else if (keyCode == ALT) {
      altDown = false;
    } else if (keyCode == SHIFT) {
      shiftDown = false;
    }
  }
}

class PaintShape
{
  int x,y,kind;
  float rotation = 0;
  float ORIGINAL_SIZE = 32.0;
  // Size of the bounding box
  float sizeX = ORIGINAL_SIZE;
  float sizeY = ORIGINAL_SIZE;
  PShape pShape;
  PaintShape(int _x, int _y, int _kind)
  {
    x = _x;
    y = _y;
    kind = _kind;
    pShape = createShape(kind, 0, 0, sizeX, sizeY);
    pShape.translate(x, y);

    pShape.setFill(color(random(255), random(255), random(255)));
  }

  void updateMatrix()
  {
    pShape.translate(x+sizeX/2, y+sizeY/2);
    pShape.rotate(rotation);
    pShape.translate(-x-sizeX/2, -y-sizeY/2);
    float scalePercentageX = sizeX/ORIGINAL_SIZE;
    float scalePercentageY = sizeY/ORIGINAL_SIZE;
    pShape.scale(sizeX/ORIGINAL_SIZE, sizeY/ORIGINAL_SIZE);
    pShape.translate(x/scalePercentageX, y/scalePercentageY);
  }

  float getCenterX() {
    return x + sizeX / 2;
  }

  float getCenterY() {
    return y + sizeY / 2;
  }

  void draw(float pointerX, float pointerY)
  {
    pShape.setStroke(false);
    if (isHoover(pointerX, pointerY))
    {
      pShape.resetMatrix();
      pShape.setStroke(true);
      pShape.setStroke(color(100, 100 ,200));
      if (controlDown) {
        float angle = atan2(pointerY - getCenterY(), pointerX - getCenterX());
        rotation = angle;

      } else if (shiftDown) {
        x += deltaX;
        y += deltaY;
      } else if (altDown) {
        sizeX *= 1 + deltaX/sizeX;
        sizeY *= 1 + deltaY/sizeY;
      }
      updateMatrix();
    }
    shape(pShape);
  }

  boolean isHoover(float cursorX, float cursorY)
  {
    if (lockedShape == this) {
      return true;
    } else if (lockedShape != null) {
      return false;
    }
    if (cursorX > x
        && cursorX < x+sizeX
        && cursorY > y
        && cursorY < y+sizeY)
    {
      lockedShape = this;
      return true;
    }
    else
    {
      return false;
    }
  }
}
