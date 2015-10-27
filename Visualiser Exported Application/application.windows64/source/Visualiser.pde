import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

Minim minim;
MusicPlayer player;
AudioMetaData meta;
WaveformRenderer waveform;
BeatDetect beat;

float volume = 0;
float maxVolume = 0;

PFont font;

float rotX = 0;
float rotY = 0;
float rotZ = 0;

float oldX = -1;
float oldY = -1;

int rightClickShift = 255;

float xmag, ymag = 0;
float newXmag, newYmag = 0; 

int numFireflies = 50;
int fireFlySpread = 100;
float flashChance = 0.001;

float maxCoord = 800;

int depthMax = 7;
float subcubeChance = 1;

float zoom = 2;
float zoomMax = 300;

cube[] cubes;
int cubeNo = (int)random(4, 8);

boolean faceCamera = false;

void setup() {
  size(1280, 720, OPENGL);

  minim = new Minim(this);
  waveform = new WaveformRenderer(4);
  player = new MusicPlayer(minim, waveform);
  beat = new BeatDetect();

  player.play();
  //player.mute();

  font = createFont("Copperplate Gothic Light", 12, false);
  textFont(font);

  frameRate(60);
  noStroke();  
  ellipseMode(CENTER);
  sphereDetail(8);
  cubes = new cube[cubeNo];
  cubes[0] = new cube(0, 0, 0, 50, 0.001, numFireflies, fireFlySpread);
  for (int i = 1; i < cubeNo; i++) {
    float xPos = random(-500, 500);
    float yPos = random(-500, 500);
    float zPos = random(-500, 500);
    int fireflyNo = (int)random(20, 50);
    int size = (int)random(20, 80);
    int spread = (int)random(fireFlySpread-50, fireFlySpread+50);
    cubes[i] = new cube(xPos, yPos, zPos, size, random(-0.01, 0.01), fireflyNo, spread);
  }
}

void draw() {
  background(0);
  lights();
  AudioPlayer song = player.getSong();
  if (song != null){
    beat.detect(song.mix);
    checkSoundInputs(song);
  }
  

  player.update();

  newXmag+=0.001;
  float diff = xmag-newXmag;
  if (abs(diff) >  0.01) { 
    xmag -= diff/24.0;
  }

  diff = ymag-newYmag;
  if (abs(diff) >  0.01) { 
    ymag -= diff/24.0;
  }

  pushMatrix();
  translate(width/2, height/2, zoomMax-zoom);
  rotateX(-ymag); 
  drawBackUI(song);
  rotateY(-xmag);
  fill(0);
  stroke(50);
  sphere(1000);
  waveform.draw();
  drawMetadata(song);

  stroke(255, 50);
  strokeWeight(1);
  for (int i = 0; i < cubeNo; i++) {
    pushMatrix();
    rotateY(-cubes[i].rot);
    if (beat.isOnset()) {
      cubes[i].setFlash(true);
    }
    cubes[i].update();
    cubes[i].draw();
    strokeWeight(1);
    popMatrix();
  }
  popMatrix();
  drawUI();
}

void drawUI() {
  // draw controls
  pushMatrix();
  translate(width, height, 0);
  rotateX(-ymag);
  rotateY(radians(-30));
  noStroke();
  /*float shift = map(rightClickShift, 0, 255, 0, 75);
  fill(255, 80);
  rect(-165, -shift-12, 10, shift);*/
  fill(255, 150);
  text("1-9: play specific song", -150, -75);
  text("p: pause/play music", -150, -60);
  text("n: play next song", -150, -45);
  text("m: mute/unmute music", -150, -30);
  text("l-click: rotate view", -150, -15);
  
  popMatrix();

  // draw song list
  pushMatrix();
  translate(0, height, 0);
  rotateX(-ymag);
  rotateY(radians(30));
  int numSongs = player.music.length;
  int yPos = -15*numSongs;
  for (int i = 0; i < numSongs; i++) {
    String text = (i+1) + " : " + player.music[i].getMetaData().title();
    if (i == player.currentSongNo) {
      stroke(100);
      noFill();
      rect(13, yPos-12, textWidth(text)+4, 15);
      noStroke();
      fill(255, 150);
      text(text, 15, yPos);
    } else {
      text(text, 15, yPos);
    }
    yPos += 15;
  }
  popMatrix();
}

void drawBackUI(AudioPlayer song) {
  // draw song completion;
  float position = 0;
  float songLength = 100;
  if (song != null){
    position = song.position();
    songLength = song.length();
  }
  float completionAngle = map(position, 0, songLength, 0, PI);
  float zSpace = 50;

  pushMatrix();
  translate(0, 0, -700);
  rotateX(-ymag);
  noFill();
  stroke(255, 30);
  arc(0, 0, 500, 500, 0, 2*PI);
  if (beat.isOnset()) {
    stroke(255, 150);
    strokeWeight(10);
    zSpace *= 1.1;
  } else {
    stroke(255, 60);
    strokeWeight(6);
  }

  translate(0, 0, zSpace);
  // song completion arcs
  arc(0, 0, 550, 550, -PI/2, completionAngle-PI/2);
  arc(0, 0, 550, 550, PI/2, completionAngle+PI/2);

  rotateZ(completionAngle-PI/2);

  // visualiser arcs
  if (rightClickShift > 0) {
    pushMatrix();
    translate(0, 0, zSpace);
    stroke(255, 60);
    strokeWeight(6);
    float arcMap = map(rightClickShift, 0, 255, 0, 1);
    int arcWidth = 200;
    int numSamples = 15;
    int sampleStep = waveform.leftBuffer.length/numSamples;
    for (int i = 0; i < numSamples*sampleStep; i+=sampleStep){
      float arcLength = waveform.getSample(i);
      arc(0, 0, arcWidth, arcWidth+=20, -(arcMap*arcLength), arcMap*arcLength);
    }
    rotateZ(PI);
    arcWidth = 200;
    for (int i = 0; i < numSamples*sampleStep; i+=sampleStep){
      float arcLength = waveform.getSample(i);
      arc(0, 0, arcWidth, arcWidth+=20, -(arcMap*arcLength), arcMap*arcLength);
    }
    popMatrix();
  }

  translate(0, 0, zSpace/2);
  fill(255, 150);
  stroke(255, 150);
  strokeWeight(1);
  line(-275, 0, 275, 0);
  translate(0, 0, zSpace/2);
  textSize(24);
  String positionText = str(position);
  text(positionText, 285, 7);
  text(positionText, -285-textWidth(positionText), 7);
  textSize(12);

  popMatrix();
}

void drawMetadata(AudioPlayer song) {
  if (song == null){
    return;
  }
  noStroke();
  fill(255);
  String text = meta.title();
  text(text, cubes[0].size, 3);
  text = meta.author();
  text(text, -(cubes[0].size+textWidth(text)), 3);

  pushMatrix();
  rotate(radians(frameCount % 360 * 2));
  strokeWeight(1);
  stroke(255, map(volume, 0, maxVolume, 10, 100));
  for (int j = 0; j < 180; j++) {
    line(cos(j)*50, sin(j)*50, cos(j)*abs(song.left.get(j))*200 + cos(j)*50, 
      sin(j)*abs(song.right.get(j))*200 + sin(j)*50);
  }
  for (int k = 180; k > 0; k--) {
    line(cos(k)*50, sin(k)*50, cos(k)*abs(song.right.get(k))*200 + cos(k)*50, 
      sin(k)*abs(song.left.get(k))*200 + sin(k)*50);
  }

  popMatrix();
}

void checkSoundInputs(AudioPlayer song) {
  float tempVol = song.mix.level();
  volume = tempVol;
  if (volume > maxVolume) {
    maxVolume = volume;
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
      if (newYmag > 1.5) {
        newYmag = 1.5;
      } else if (newYmag < -1.5) {
        newYmag = -1.5;
      }
    }
    oldX = mouseX;
    oldY = mouseY;
  } else if (mouseButton == RIGHT) {
    if (oldX >= 0 && oldY >= 0) {
      int yDiff = (int)(mouseY-oldY);
      rightClickShift -= yDiff;
      if (rightClickShift > 255) {
        rightClickShift = 255;
      } else if (rightClickShift < 0) {
        rightClickShift = 0;
      }
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
  if (key == 'f') {
    faceCamera = !faceCamera;
    return;
  } else if (key == 'p') {
    player.playPause();
    return;
  } else if (key == 'n') {
    player.playNext();
    return;
  } else if (key == 'm') {
    player.mute();
    return;
  } else {
    checkNumbers(key);
  }
}

void checkNumbers(char key) {
  int maxSongNo = player.fileNo;
  if (key == '1' && 1 <= maxSongNo) {
    player.changeSong(0);
  } else if (key == '2' && 2 <= maxSongNo) {
    player.changeSong(1);
  } else if (key == '3' && 3 <= maxSongNo) {
    player.changeSong(2);
  } else if (key == '4' && 4 <= maxSongNo) {
    player.changeSong(3);
  } else if (key == '5' && 5 <= maxSongNo) {
    player.changeSong(4);
  } else if (key == '6' && 6 <= maxSongNo) {
    player.changeSong(5);
  } else if (key == '7' && 7 <= maxSongNo) {
    player.changeSong(6);
  } else if (key == '8' && 8 <= maxSongNo) {
    player.changeSong(7);
  } else if (key == '9' && 9 <= maxSongNo) {
    player.changeSong(8);
  }
}

void stop() {

  player.close();
  minim.stop();
  super.stop();
}