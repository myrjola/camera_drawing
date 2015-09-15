// Axis-aligned-bounding box in 2D
class AABB2D
{
  float centerX, centerY, halfWidth, halfHeight;
  float rotation = 0;

  PVector p1 = new PVector(0, 0),
    p2 = new PVector(0, 0),
    p3 = new PVector(0, 0),
    p4 = new PVector(0, 0);

  float minX, maxX, minY, maxY;

  AABB2D(float _centerX, float _centerY, float width, float height)
  {
    centerX = _centerX;
    centerY = _centerY;
    halfWidth = width / 2;
    halfHeight = height / 2;
    updateMinMax();
  }

  void setRotation(float _rotation)
  {
    rotation = _rotation;
    updateMinMax();
  }

  void setCenter(float x, float y)
  {
    centerX = x;
    centerY = y;
    updateMinMax();
  }

  void setSize(float width, float height)
  {
    halfWidth = width / 2;
    halfHeight = height / 2;
    updateMinMax();
  }

  void updateMinMax()
  {
    p1.set(-halfWidth, -halfHeight);
    p2.set(-halfWidth, halfHeight);
    p3.set(halfWidth, -halfHeight);
    p4.set(halfWidth, halfHeight);
    p1.rotate(rotation);
    p2.rotate(rotation);
    p3.rotate(rotation);
    p4.rotate(rotation);
    float[] xValues = { p1.x, p2.x, p3.x, p4.x };
    float[] yValues = { p1.y, p2.y, p3.y, p4.y };
    minX = min(xValues) + centerX;
    minY = min(yValues) + centerY;
    maxX = max(xValues) + centerX;
    maxY = max(yValues) + centerY;
  }
}
