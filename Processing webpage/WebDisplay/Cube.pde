class cube {
  float xPos, yPos, zPos;
  float rot;
  float rotSpeed;
  int size;
  int flashCount = 0;
  int flashMax = 30;
  cube subcube;
  cube subcube2;
  firefly[] fireflies;

  cube(float x, float y, float z, int s, float rotS, int fireflyNo, int fireflyDist) {
    xPos = x;
    yPos = y;
    zPos = z;
    size = s;
    rot = 0;
    rotSpeed = rotS;
    fireflies = new firefly[fireflyNo];
    for (int i = 0; i < fireflyNo; i++) {
      fireflies[i] = new firefly(fireflyDist);
    }
  }

  void draw() {
    pushMatrix();
    translate(xPos, yPos, zPos);
    rotateY(rot);
    fill(255, 0, 0, map(flashCount, 0, flashMax, 0, 255));
    noStroke();
    if (flashCount > 0) {
      drawInner();
    }
    sphere(size/2);

    for (int i = 0; i < fireflies.length; i++) {
      fireflies[i].update();
      if (random(0, 1) < flashChance) {
        int i0 = i-1;
        int i1 = i;
        int i2 = i+1;
        int i3 = i+2;
        if (i1 < 1) {
          i0 = fireflies.length-1;
        }
        if (i1 > fireflies.length-2) {
          i2 = 0;
          i3 = 1;
        } else if (i1 > fireflies.length-3) {
          i3 = 0;
        }
        fireflies[i1].setFlash(true);
        fireflies[i2].setFlash(true);
        noFill();
        stroke(255, 50 + random(-50, 50));
        strokeWeight(3);
        drawCurves(i0, i1, i2, i3);
        stroke(255, 100 + random(-100, 100));
        strokeWeight(1);
        drawCurves(i0, i1, i2, i3);
      }
      fireflies[i].draw(xmag-rot, ymag);
    }
    popMatrix();
  }

  void update() {
    rot += rotSpeed;
    if (flashCount > 0) {
      flashCount--;
    }
  }

  void drawInner() {
    int innerBoxes = (int)random(0, 5);
    for (int i = 0; i <= innerBoxes; i++) {
      float innerBoxSize = random(1, size/2);
      float translation = size-innerBoxSize;
      pushMatrix();
      translate(random(-translation, translation), 
        random(-translation, translation), 
        random(-translation, translation));
      rotateY(xmag-rot);
      rotateX(ymag);
      rect(-innerBoxSize/2, -innerBoxSize/2, innerBoxSize, innerBoxSize);
      popMatrix();
    }
  }

  void drawCurves(int i0, int i1, int i2, int i3) {
    curve(fireflies[i0].xPos, fireflies[i0].yPos, fireflies[i0].zPos, 
      fireflies[i1].xPos, fireflies[i1].yPos, fireflies[i1].zPos, 
      fireflies[i2].xPos, fireflies[i2].yPos, fireflies[i2].zPos, 
      fireflies[i3].xPos, fireflies[i3].yPos, fireflies[i3].zPos);
    bezier(fireflies[i0].xPos, fireflies[i0].yPos, fireflies[i0].zPos, 
      fireflies[i1].xPos, fireflies[i1].yPos, fireflies[i1].zPos, 
      fireflies[i2].xPos, fireflies[i2].yPos, fireflies[i2].zPos, 
      fireflies[i3].xPos, fireflies[i3].yPos, fireflies[i3].zPos);
  }

  void setFlash(boolean flashing) {
    if (flashing) {
      flashCount = flashMax;
    } else {
      flashCount = 0;
    }
  }
}