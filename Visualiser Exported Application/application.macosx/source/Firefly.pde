class firefly {
  float xPos, yPos, zPos;
  float xVel, yVel, zVel;
  float xRot, yRot;
  boolean flash;
  boolean outOfBounds;
  float maxVel = 0.2;
  float dragSpeed = 0.02;
  float flashSpeedMod = 3;
  float maxVelDrag = 0.98;

  firefly (int max) {
    xPos = random(-max, max);
    yPos = random(-max, max);
    zPos = random(-max, max);
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
      fill(255, map(getSpeed(), 0, maxVel*2, 0, 100));
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
    int maxDist = (int)(volume*1000);
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
    
    if (getDistFromMid() > maxCoord){
      xPos = 0;
      yPos = 0;
      zPos = 0;
    } 
    if (getSpeed() > maxVel) {
      xVel *= maxVelDrag;
      yVel *= maxVelDrag;
      zVel *= maxVelDrag;
    }
  }

  void setFlash(boolean flashing) {
    flash = flashing;
    if (flashing && !outOfBounds) {
      xVel *= flashSpeedMod;
      yVel *= flashSpeedMod;
      zVel *= flashSpeedMod;
    }
  }
  
  float getSpeed(){
    return sqrt(pow(abs(xVel),2)+pow(abs(yVel),2)+pow(abs(zVel),2));
  }
  
  float getDistFromMid(){
    return sqrt(pow(abs(xPos),2)+pow(abs(yPos),2)+pow(abs(zPos),2));
  }
}
