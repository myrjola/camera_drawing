ArrayList<PaintShape> paintShapes = new ArrayList<PaintShape>();

float lastCursorX, lastCursorY, deltaX, deltaY;

boolean controlDown, shiftDown, altDown;

boolean choosingFillColorInProgress;

boolean choosingTrackedColorInProgress;

boolean debugMode = false;

color fillColor = color(155);

CameraPointer pointer;

PaintShape lockedShape = null;

int lockedShapeIndex;

void setup()
{
  size(1280, 720, P2D);
  pointer = new CameraPointer(this);
}

void draw()
{
  if (choosingFillColorInProgress || choosingTrackedColorInProgress) {
    background(color(255));
    color chosenColor = color(255);

    if (pointer.video != null) {
      pointer.updateCamera(true);

      pushMatrix();
      scale(-1.0, 1.0);
      translate(-width, 0);
      image(pointer.video, 0, 0);
      popMatrix();

      // Choose the color from the middle of the picture
      chosenColor = color(pointer.video.pixels[pointer.video.width *
                                               pointer.video.height / 2 +
                                               pointer.video.width / 2]);
      if (choosingFillColorInProgress) {
        fillColor = chosenColor;
      } else if (choosingTrackedColorInProgress) {
        pointer.trackedColor = chosenColor;
      }
    }
    fill(255);
    rect(0, 0, 128, 130);

    // Draw cross
    int crossRadius = 32;
    line(width/2 - crossRadius, height/2 - crossRadius,
         width/2 + crossRadius, height/2 + crossRadius);
    line(width/2 - crossRadius, height/2 + crossRadius,
         width/2 + crossRadius, height/2 - crossRadius);

    fill(50);
    text("Chosen color:", 5, 12);
    fill(chosenColor);
    rect(0, 14, 128, 130);

  } else {
    paintProgramDraw();
  }
}

void paintProgramDraw()
{
  background(color(255));

  // Draw help text
  fill(50);
  text("'e' - create ellipse\n'r' - create rectangle\n" +
       "'x' - remove object\n't' - choose tracked color\n" +
       "'c' - choose fill color\n'd' - debug mode\n" +
       "Shift/Ctrl/Alt - translate/rotate/scale",
       5, 12);

  pointer.update(debugMode);
  float pointerX = pointer.x;
  float pointerY = pointer.y;
  deltaX = pointerX - lastCursorX;
  deltaY = pointerY - lastCursorY;
  lastCursorX = pointerX;
  lastCursorY = pointerY;

  if (debugMode && shiftDown) {
    if (pointerX != pointer.x) {
      println("pointerX: " + pointerX);
      println("pointer.x" + pointer.x);
    }
    if (pointerY != pointer.y) {
      println("pointerY: " + pointerY);
      println("pointer.y" + pointer.y);
    }
    if (lastCursorX != pointer.lastX) {
      println("lastCursorX: " + lastCursorX);
      println("pointer.lastX" + pointer.lastX);
    }
    if (lastCursorY != pointer.lastY) {
      println("lastCursorY: " + lastCursorY);
      println("pointer.lastY" + pointer.lastY);
    }
  }

  if (!keyPressed) {
    lockedShape = null;
  }
  lockedShapeIndex = paintShapes.size();
  for (int i = 0; i < paintShapes.size(); i++)
  {
    boolean hooveredOn = paintShapes.get(i).draw(pointerX, pointerY);
    if (hooveredOn) {
      lockedShapeIndex = i;
    }
  }

  if (lockedShapeIndex < paintShapes.size() && shiftDown) {
    // Move the locked shape to the front if a translation is in progress
    PaintShape movedObject = paintShapes.remove(lockedShapeIndex);
    // Painted in the front means last in the list
    paintShapes.add(movedObject);
  }

  // Draw a rotation arm
  if (controlDown && lockedShape != null) {
    line(lockedShape.getCenterX(), lockedShape.getCenterY(), pointerX, pointerY);
  }

  // Draw a circle at the cursor;
  fill(pointer.trackedColor);
  pushMatrix();
  translate(pointer.x, pointer.y);
  ellipse(0, 0, 10, 10);
  popMatrix();
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
    paintShapes.add(new PaintShape(int(pointer.x), int(pointer.y), ELLIPSE));
  } else if (key == 'r') {
    paintShapes.add(new PaintShape(int(pointer.x), int(pointer.y), RECT));
  } else if (key == 'x') {
    if (lockedShape != null) {
      paintShapes.remove(lockedShapeIndex);
    }
  } else if (key == 'c') {
    choosingFillColorInProgress = true;
  } else if (key == 't') {
    choosingTrackedColorInProgress = true;
  } else if (key == 'd' && debugMode) {
    debugMode = false;
  } else if (key == 'd' && !debugMode) {
    debugMode = true;
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
  } else if (key == 'c') {
    choosingFillColorInProgress = false;
  } else if (key == 't') {
    choosingTrackedColorInProgress = false;
  }
}

class PaintShape
{
  int kind;
  float x, y, rotation;
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
    boundingBox = new AABB2D(x, y, sizeX, sizeY);
    pShape.setFill(fillColor);
  }

  void updateMatrix()
  {
    translate(x, y);
    translate(sizeX / 2, sizeY / 2);
    rotate(rotation);
    translate(- sizeX / 2, - sizeY / 2);
    float scalePercentageX = sizeX/ORIGINAL_SIZE;
    float scalePercentageY = sizeY/ORIGINAL_SIZE;
    scale(sizeX/ORIGINAL_SIZE, sizeY/ORIGINAL_SIZE);
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
      pShape.setStroke(true);
      pShape.setStroke(color(100, 100, 200));
      if (controlDown) {
        float angle = atan2(pointerY - getCenterY(), pointerX - getCenterX());
        // Normalize the rotation to [0, 2*PI]
        rotation = (angle + 2 * PI) % (2*PI);

      } else if (shiftDown) {
        x += deltaX;
        y += deltaY;
      } else if (altDown) {

        // We have to account for rotation to make a more natural scaling.
        PVector rotatedDelta = new PVector(deltaX, deltaY);
        rotatedDelta.rotate(rotation);

        // Also originally positive deltas should be positive rotatedDeltas.
        // This needs some axis inverting.
        if (rotation >= 7 * QUARTER_PI) {
          // Nothing needs to be done, but this is cleaner like this.
        } else if (rotation >= 5 * QUARTER_PI) {
          rotatedDelta.y = -rotatedDelta.y;
        } else if (rotation >= 3 * QUARTER_PI) {
            rotatedDelta.x = -rotatedDelta.x;
            rotatedDelta.y = -rotatedDelta.y;
        } else if (rotation >= QUARTER_PI) {
          rotatedDelta.x = -rotatedDelta.x;
        }

        sizeX *= 1 + rotatedDelta.x/sizeX;
        sizeY *= 1 + rotatedDelta.y/sizeY;
      }
    }
    pushMatrix();
    updateMatrix();
    shape(pShape);
    popMatrix();

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
