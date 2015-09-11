
ArrayList<PaintShape> particles = new ArrayList<PaintShape>();

int lastCursorX, lastCursorY, deltaX, deltaY;

boolean controlDown, shiftDown, altDown;

void setup()
{
  size(640, 360, P2D);
  background(color(200));
  for (int i=0; i<10; i++)
  {
    particles.add(new PaintShape(i*40, height/2, RECT));
  }
}

void draw()
{
  deltaX = mouseX - lastCursorX;
  deltaY = mouseY - lastCursorY;
  lastCursorX = mouseX;
  lastCursorY = mouseY;
  background(color(200));
  for (int i=0; i<particles.size(); i++)
  {
    particles.get(i).draw();
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
    pShape = createShape(RECT, 0, 0, sizeX, sizeY);
    pShape.translate(x, y);
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

  void draw()
  {
    pShape.setStroke(false);
    if (isHoover(mouseX, mouseY))
    {
      pShape.resetMatrix();
      pShape.setStroke(true);
      pShape.setStroke(color(100, 100 ,200));
      if (controlDown) {
        rotation += 0.01;
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

  boolean isHoover(int cursorX, int cursorY)
  {
    if (cursorX > x
        && cursorX < x+sizeX
        && cursorY > y
        && cursorY < y+sizeY)
    {
      return true;
    }
    else
    {
      return false;
    }
  }
}
