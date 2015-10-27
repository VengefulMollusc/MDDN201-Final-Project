float rotX = 0;
float rotY = 0;
float rotZ = 0;

float oldX = -1;
float oldY = -1;

float xmag, ymag = 0;
float newXmag, newYmag = 0; 

int numFireflies = 80;
int fireFlySpread = 100;
float flashChance = 0.001;

int depthMax = 7;
float subcubeChance = 1;

float zoom = 2;
float zoomMax = 300;

cube[] cubes;
int cubeNo = (int)random(2, 10);

boolean faceCamera = false;

void setup() {
  size(1280, 720, OPENGL);
  frameRate(60);
  noStroke();  
  ellipseMode(CENTER);
  sphereDetail(8);
  cubes = new cube[cubeNo];
  cubes[0] = new cube(0, 0, 0, 50, 0.001, numFireflies, fireFlySpread);
  for (int i = 1; i < cubeNo; i++) {
    float xPos = random(-300, 300);
    float yPos = random(-300, 300);
    float zPos = random(-300, 300);
    cubes[i] = new cube(xPos, yPos, zPos, 50, 0.001, numFireflies, fireFlySpread);
  }
}

void draw() {
  background(0);
  lights();
  
  newXmag+=0.001;
  float diff = xmag-newXmag;
  if (abs(diff) >  0.01) { 
    xmag -= diff/24.0;
  }

  diff = ymag-newYmag;
  if (abs(diff) >  0.01) { 
    ymag -= diff/24.0;
  }

  translate(width/2, height/2, zoomMax-zoom);
  rotateX(-ymag); 
  rotateY(-xmag);
  fill(0);
  sphere(1000);

  for (int i = 0; i < cubeNo; i++) {
    if (random(0, 1) < flashChance*5) {
        int i0 = i-1;
        int i1 = i;
        int i2 = i+1;
        int i3 = i+2;
        if (i1 < 1) {
          i0 = cubeNo-1;
        }
        if (i1 > cubeNo-2) {
          i2 = 0;
          i3 = 1;
        } else if (i1 > cubeNo-3) {
          i3 = 0;
        }
        cubes[i1].setFlash(true);
        cubes[i2].setFlash(true);
        noFill();
        stroke(255, 50, 50, 50 + random(-50, 50));
        strokeWeight(10);
        drawCurves(i0, i1, i2, i3);
        stroke(255, 50, 50, 100 + random(-100, 100));
        strokeWeight(4);
        drawCurves(i0, i1, i2, i3);
      }
  }
  
  stroke(255, 50);
  strokeWeight(1);
  for (int i = 0; i < cubeNo; i++) {
    pushMatrix();
    cubes[i].update();
    cubes[i].draw();
    popMatrix();
  }
}

void mousePressed() {
  oldX = -1;
  oldY = -1;
}

void drawPoint() {
  rotateY(xmag);
  rotateX(ymag);
  float random = 0;
  fill(255, 240, 0, 8);
  random = random(-1, 1);
  ellipse(0, 0, 20+random, 20+random);
  fill(255, 240, 50, 8);
  random = random(-0.8, 0.8);
  ellipse(0, 0, 10+random, 10+random);
  fill(255, 240, 150, 16);
  random = random(-0.6, 0.6);
  ellipse(0, 0, 5+random, 5+random);
  fill(255, 240, 200, 40);
  random = random(-0.4, 0.4);
  ellipse(0, 0, 4+random, 4+random);
  fill(255, 220);
  random = random(-0.2, 0.2);
  ellipse(0, 0, 2+random, 2+random);
}

void mouseDragged() {
  if (mouseButton == LEFT) {
    if (oldX >= 0 && oldY >= 0) {
      float xDiff = mouseX-oldX;
      float yDiff = mouseY-oldY;
      newXmag -= xDiff/float(width) * TWO_PI;
      newYmag += yDiff/float(height) * TWO_PI;
    }
    oldX = mouseX;
    oldY = mouseY;
  }
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  if (e >= 0) {
    zoom /= 0.8;
  } else {
    zoom *= 0.8;
  }
  if (zoom > 635) {
    zoom = 635;
  }
  if (zoom < 10) {
    zoom = 10;
  }
}

void keyPressed() {
  if (key == '1') {
    faceCamera = !faceCamera;
  }
}

void drawCurves(int i0, int i1, int i2, int i3) {
    curve(cubes[i0].xPos, cubes[i0].yPos, cubes[i0].zPos, 
      cubes[i1].xPos, cubes[i1].yPos, cubes[i1].zPos, 
      cubes[i2].xPos, cubes[i2].yPos, cubes[i2].zPos, 
      cubes[i3].xPos, cubes[i3].yPos, cubes[i3].zPos);
    bezier(cubes[i0].xPos, cubes[i0].yPos, cubes[i0].zPos, 
      cubes[i1].xPos, cubes[i1].yPos, cubes[i1].zPos, 
      cubes[i2].xPos, cubes[i2].yPos, cubes[i2].zPos, 
      cubes[i3].xPos, cubes[i3].yPos, cubes[i3].zPos);
  }