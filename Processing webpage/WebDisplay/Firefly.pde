class firefly {
  float xPos, yPos, zPos;
  float xVel, yVel, zVel;
  float xRot, yRot;
  int maxDist;
  boolean flash;
  boolean outOfBounds;
  float maxVel = 0.2;
  float dragSpeed = 0.02;

  firefly (int max) {
    maxDist = max;
    xPos = random(-maxDist, maxDist);
    yPos = random(-maxDist, maxDist);
    zPos = random(-maxDist, maxDist);
    flash = false;
    outOfBounds = false;
  }

  void draw(float xmag, float ymag) {
    pushMatrix();
    stroke(255, 50);
    line(0, 0, 0, xPos, yPos, zPos);
    translate(xPos, yPos, zPos);
    xRot = -atan2(yPos, zPos);
    yRot = atan2(xPos*cos(xRot), zPos);

    if (faceCamera) {
      rotateY(xmag);
      rotateX(ymag);
    } else {
      rotateX(xRot);
      rotateY(yRot);
    }
    if (flash) {
      fill(255);
      ellipse(0, 0, 15, 15);
    } else {
      fill(255, map(getSpeed(), 0, maxVel*2, 0, 200));
      ellipse(0, 0, 10, 10);
    }
    popMatrix();
    flash = false;
  }

  void update() {

    updateVel();

    xPos += xVel;
    yPos += yVel;
    zPos += zVel;
  }

  void updateVel() {
    outOfBounds = true;
    if (xPos < -maxDist) {
      xVel += random(0, dragSpeed);
    } else if (xPos > maxDist) {
      xVel += random(-dragSpeed, 0);
    } else {
      outOfBounds = false;
      xVel += random(-0.01, 0.01);
    }

    if (yPos < -maxDist) {
      yVel += random(0, dragSpeed);
    } else if (yPos > maxDist) {
      yVel += random(-dragSpeed, 0);
    } else {
      outOfBounds = false;
      yVel += random(-0.01, 0.01);
    }

    if (zPos < -maxDist) {
      zVel += random(0, dragSpeed);
    } else if (zPos > maxDist) {
      zVel += random(-dragSpeed, 0);
    } else {
      outOfBounds = false;
      zVel += random(-0.01, 0.01);
    }
    if (getSpeed() > maxVel) {
      xVel *= 0.98;
      yVel *= 0.98;
      zVel *= 0.98;
    }
  }

  void setFlash(boolean flashing) {
    flash = flashing;
    if (flashing && !outOfBounds) {
      xVel *= 5;
      yVel *= 5;
      zVel *= 5;
    }
  }
  
  float getSpeed(){
    return sqrt(pow(abs(xVel),2)+pow(abs(yVel),2)+pow(abs(zVel),2));
  }
}