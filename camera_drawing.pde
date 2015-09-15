
ArrayList<PaintShape> paintShapes = new ArrayList<PaintShape>();

float lastCursorX, lastCursorY, deltaX, deltaY;

boolean controlDown, shiftDown, altDown;

PaintShape lockedShape = null;

void setup()
{
  size(640, 360, P2D);
}

void draw()
{
  background(color(255));

  // Draw help text
  fill(50);
  text("'e' - create ellipse\n'r' - create rectangle\nShift/Ctrl/Alt - translate/rotate/scale",
       5, 12);

  float pointerX = mouseX;
  float pointerY = mouseY;
  deltaX = pointerX - lastCursorX;
  deltaY = pointerY - lastCursorY;
  lastCursorX = pointerX;
  lastCursorY = pointerY;

  if (!controlDown && !shiftDown && !altDown) {
    lockedShape = null;
  }
  int lockedShapeIndex = -1;
  for (int i = 0; i < paintShapes.size(); i++)
  {
    boolean hooveredOn = paintShapes.get(i).draw(mouseX, mouseY);
    if (hooveredOn) {
      lockedShapeIndex = i;
    }
  }

  if (lockedShapeIndex > 0 && shiftDown) {
    // Move the locked shape to the front if a translation is in progress
    PaintShape movedObject = paintShapes.remove(lockedShapeIndex);
    // Painted in the front means last in the list
    paintShapes.add(movedObject);
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
    paintShapes.add(new PaintShape(mouseX, mouseY, ELLIPSE));
  } else if (key == 'r') {
    paintShapes.add(new PaintShape(mouseX, mouseY, RECT));
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
  AABB2D boundingBox;

  PaintShape(int _x, int _y, int _kind)
  {
    x = _x;
    y = _y;
    kind = _kind;
    pShape = createShape(kind, 0, 0, sizeX, sizeY);
    pShape.translate(x, y);
    boundingBox = new AABB2D(x, y, sizeX, sizeY);

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
    boundingBox.setRotation(rotation);
    boundingBox.setSize(sizeX, sizeY);
    boundingBox.setCenter(x+sizeX/2, y+sizeY/2);
  }

  float getCenterX() {
    return x + sizeX / 2;
  }

  float getCenterY() {
    return y + sizeY / 2;
  }

  // Returns true if there's a hoover over the shape.
  boolean draw(float pointerX, float pointerY)
  {
    pShape.setStroke(false);
    boolean hooveredOn = false;
    if (isHoover(pointerX, pointerY))
    {
      hooveredOn = true;
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

    return hooveredOn;
  }

  // Collision detection based on the bounding box
  boolean isHoover(float cursorX, float cursorY)
  {
    if (lockedShape == this) {
      return true;
    } else if (lockedShape != null) {
      return false;
    } if (cursorX > boundingBox.minX
          && cursorX < boundingBox.maxX
          && cursorY > boundingBox.minY
          && cursorY < boundingBox.maxY) {
      lockedShape = this;
      return true;
    } else {
      return false;
    }
  }
}
