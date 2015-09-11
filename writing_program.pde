
ArrayList<PaintShape> particles = new ArrayList<PaintShape>();


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
  background(color(200));
  for (int i=0; i<particles.size(); i++)
  {
    particles.get(i).draw() ;
  }
}


class PaintShape
{
  int x,y,kind;
  float rotation;
  // Size of the bounding box
  int sizeX = 32, sizeY = 32;
  PShape pShape;
  PaintShape(int _x, int _y, int _kind)
  {
    x = _x;
    y = _y;
    kind = _kind;
    pShape = createShape(RECT, 0, 0, sizeX, sizeY);
    pShape.translate(x, y);
  }

  int getCenterX()
  {
    return x + sizeX/2;
  }

  int getCenterY()
  {
    return y + sizeY/2;
  }

  void draw()
  {
    pShape.setStroke(false);
    if(isOver(mouseX, mouseY))
    {
      pShape.setStroke(true);
      pShape.setStroke(color(100, 100 ,200));
      pShape.translate(sizeX/2, sizeY/2);
      pShape.rotate(0.01);
      pShape.translate(-sizeX/2, -sizeY/2);
   }
    shape(pShape);
  }

  boolean isOver(int mx, int my)
  {
    if (mx > x
        && mx < x+sizeX
        && my > y
        && my < y+sizeY)
    {
      return true;
    }
    else
    {
      return false;
    }
  }
  int where(int mmx, int mmy)
  {

    return mmx-x;

  }

}
