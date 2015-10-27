import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import ddf.minim.*; 
import ddf.minim.analysis.*; 
import ddf.minim.effects.*; 
import ddf.minim.signals.*; 
import ddf.minim.spi.*; 
import ddf.minim.ugens.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Visualiser extends PApplet {








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
float flashChance = 0.001f;

float maxCoord = 800;

int depthMax = 7;
float subcubeChance = 1;

float zoom = 2;
float zoomMax = 300;

cube[] cubes;
int cubeNo = (int)random(4, 8);

boolean faceCamera = false;

public void setup() {
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
  cubes[0] = new cube(0, 0, 0, 50, 0.001f, numFireflies, fireFlySpread);
  for (int i = 1; i < cubeNo; i++) {
    float xPos = random(-500, 500);
    float yPos = random(-500, 500);
    float zPos = random(-500, 500);
    int fireflyNo = (int)random(20, 50);
    int size = (int)random(20, 80);
    int spread = (int)random(fireFlySpread-50, fireFlySpread+50);
    cubes[i] = new cube(xPos, yPos, zPos, size, random(-0.01f, 0.01f), fireflyNo, spread);
  }
}

public void draw() {
  background(0);
  lights();
  AudioPlayer song = player.getSong();
  if (song != null){
    beat.detect(song.mix);
    checkSoundInputs(song);
  }
  

  player.update();

  newXmag+=0.001f;
  float diff = xmag-newXmag;
  if (abs(diff) >  0.01f) { 
    xmag -= diff/24.0f;
  }

  diff = ymag-newYmag;
  if (abs(diff) >  0.01f) { 
    ymag -= diff/24.0f;
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

public void drawUI() {
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

public void drawBackUI(AudioPlayer song) {
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
    zSpace *= 1.1f;
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

public void drawMetadata(AudioPlayer song) {
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

public void checkSoundInputs(AudioPlayer song) {
  float tempVol = song.mix.level();
  volume = tempVol;
  if (volume > maxVolume) {
    maxVolume = volume;
  }
}

public void mousePressed() {
  oldX = -1;
  oldY = -1;
}

public void drawPoint() {
  rotateY(xmag);
  rotateX(ymag);
  float random = 0;
  fill(255, 240, 0, 8);
  random = random(-1, 1);
  ellipse(0, 0, 20+random, 20+random);
  fill(255, 240, 50, 8);
  random = random(-0.8f, 0.8f);
  ellipse(0, 0, 10+random, 10+random);
  fill(255, 240, 150, 16);
  random = random(-0.6f, 0.6f);
  ellipse(0, 0, 5+random, 5+random);
  fill(255, 240, 200, 40);
  random = random(-0.4f, 0.4f);
  ellipse(0, 0, 4+random, 4+random);
  fill(255, 220);
  random = random(-0.2f, 0.2f);
  ellipse(0, 0, 2+random, 2+random);
}

public void mouseDragged() {
  if (mouseButton == LEFT) {
    if (oldX >= 0 && oldY >= 0) {
      float xDiff = mouseX-oldX;
      float yDiff = mouseY-oldY;
      newXmag -= xDiff/PApplet.parseFloat(width) * TWO_PI;
      newYmag += yDiff/PApplet.parseFloat(height) * TWO_PI;
      if (newYmag > 1.5f) {
        newYmag = 1.5f;
      } else if (newYmag < -1.5f) {
        newYmag = -1.5f;
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

public void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  if (e >= 0) {
    zoom /= 0.8f;
  } else {
    zoom *= 0.8f;
  }
  if (zoom > 635) {
    zoom = 635;
  }
  if (zoom < 10) {
    zoom = 10;
  }
}

public void keyPressed() {
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

public void checkNumbers(char key) {
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

public void stop() {

  player.close();
  minim.stop();
  super.stop();
}
class cube { // Note: technically a cube no longer
  float xPos, yPos, zPos;
  float rot;
  float rotSpeed;
  int size;
  int flashCount = 0;
  int flashMax = 20;
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

  public void draw() {
    pushMatrix();
    translate(xPos, yPos, zPos);
    rotateY(rot);
    fill(map(flashCount, 0, flashMax, 0, 255));
    noStroke();
    if (flashCount > 0) {
      drawInner();
    }
    sphere((size/2)+(flashCount/4));
    int sparkNo = -1;
    if (beat.isOnset()){
      sparkNo = (int)random(0, fireflies.length);
    }
    for (int i = 0; i < fireflies.length; i++) {
      fireflies[i].update();
      if (random(0, 1) < flashChance || i == sparkNo) {
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
        strokeWeight(map(volume, 0, maxVolume, 3, 12));
        drawCurves(i0, i1, i2, i3);
        stroke(255, 100 + random(-100, 100));
        strokeWeight(map(volume, 0, maxVolume, 1, 5));
        drawCurves(i0, i1, i2, i3);
      }
      fireflies[i].draw(xmag-rot, ymag);
    }
    popMatrix();
  }

  public void update() {
    rot += rotSpeed;
    if (flashCount > 0) {
      flashCount--;
    }
  }

  public void drawInner() {
    int innerBoxes = (int)random(0, 5);
    for (int i = 0; i <= innerBoxes; i++) {
      float innerBoxSize = random(1, size/2);
      float translation = size-innerBoxSize;
      pushMatrix();
      translate(random(-translation, translation), 
        random(-translation, translation), 
        random(-translation, translation));
      //rotateY(xmag-rot);
      //rotateX(ymag);
      rect(-innerBoxSize/2, -innerBoxSize/2, innerBoxSize, innerBoxSize);
      popMatrix();
    }
  }

  public void drawCurves(int i0, int i1, int i2, int i3) {
    curve(fireflies[i0].xPos, fireflies[i0].yPos, fireflies[i0].zPos, 
      fireflies[i1].xPos, fireflies[i1].yPos, fireflies[i1].zPos, 
      fireflies[i2].xPos, fireflies[i2].yPos, fireflies[i2].zPos, 
      fireflies[i3].xPos, fireflies[i3].yPos, fireflies[i3].zPos);
    bezier(fireflies[i0].xPos, fireflies[i0].yPos, fireflies[i0].zPos, 
      fireflies[i1].xPos, fireflies[i1].yPos, fireflies[i1].zPos, 
      fireflies[i2].xPos, fireflies[i2].yPos, fireflies[i2].zPos, 
      fireflies[i3].xPos, fireflies[i3].yPos, fireflies[i3].zPos);
  }

  public void setFlash(boolean flashing) {
    if (flashing) {
      flashCount = flashMax;
    } else {
      flashCount = 0;
    }
  }
}
class firefly {
  float xPos, yPos, zPos;
  float xVel, yVel, zVel;
  float xRot, yRot;
  boolean flash;
  boolean outOfBounds;
  float maxVel = 0.2f;
  float dragSpeed = 0.02f;
  float flashSpeedMod = 3;
  float maxVelDrag = 0.98f;

  firefly (int max) {
    xPos = random(-max, max);
    yPos = random(-max, max);
    zPos = random(-max, max);
    flash = false;
    outOfBounds = false;
  }

  public void draw(float xmag, float ymag) {
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

  public void update() {

    updateVel();

    xPos += xVel;
    yPos += yVel;
    zPos += zVel;
  }

  public void updateVel() {
    outOfBounds = true;
    int maxDist = (int)(volume*1000);
    if (xPos < -maxDist) {
      xVel += random(0, dragSpeed);
    } else if (xPos > maxDist) {
      xVel += random(-dragSpeed, 0);
    } else {
      outOfBounds = false;
      xVel += random(-0.01f, 0.01f);
    }

    if (yPos < -maxDist) {
      yVel += random(0, dragSpeed);
    } else if (yPos > maxDist) {
      yVel += random(-dragSpeed, 0);
    } else {
      outOfBounds = false;
      yVel += random(-0.01f, 0.01f);
    }

    if (zPos < -maxDist) {
      zVel += random(0, dragSpeed);
    } else if (zPos > maxDist) {
      zVel += random(-dragSpeed, 0);
    } else {
      outOfBounds = false;
      zVel += random(-0.01f, 0.01f);
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

  public void setFlash(boolean flashing) {
    flash = flashing;
    if (flashing && !outOfBounds) {
      xVel *= flashSpeedMod;
      yVel *= flashSpeedMod;
      zVel *= flashSpeedMod;
    }
  }
  
  public float getSpeed(){
    return sqrt(pow(abs(xVel),2)+pow(abs(yVel),2)+pow(abs(zVel),2));
  }
  
  public float getDistFromMid(){
    return sqrt(pow(abs(xPos),2)+pow(abs(yPos),2)+pow(abs(zPos),2));
  }
}
class MusicPlayer{
  Minim minim;
  AudioPlayer[] music;
  int fileNo = 9;
  int currentSongNo = 0;
  boolean muted = false;
  boolean paused = false;
  
  MusicPlayer(Minim m, WaveformRenderer waveform){
    music = new AudioPlayer[fileNo];
    minim = m;
    loadMusic(waveform);
  }
  
  public void loadMusic(WaveformRenderer waveform){
    for (int i = 0; i < fileNo; i++){
      music[i] = minim.loadFile("song" + i + ".mp3");
    }
    
    for (int i = 0; i < fileNo; i++){
      music[i].addListener(waveform);
    }
  }
  
  public void update(){
    if (currentSongNo >= fileNo){
      return;
    }
    if (!music[currentSongNo].isPlaying() && !paused){
      playNext();
    }
  }
  
  public void play(){
    if (currentSongNo >= fileNo){
      return;
    }
    music[currentSongNo].play();
    meta = music[currentSongNo].getMetaData();
  }
  
  public void playPause(){
    if (currentSongNo >= fileNo){
      return;
    }
    if (music[currentSongNo].isPlaying()){
      music[currentSongNo].pause();
      paused = true;
    } else {
      music[currentSongNo].play();
      paused = false;
    }
  }
  
  public void playNext(){
    if (music[currentSongNo].isPlaying()){
      music[currentSongNo].pause();
    }
    music[currentSongNo].rewind();
    currentSongNo++;
    if (currentSongNo >= fileNo){
      currentSongNo = 0;
    }
    play();
  }
  
  public void mute(){
    if (!muted){
      for (int i = 0; i < fileNo; i++){
        music[i].mute();
      }
    } else {
      for (int i = 0; i < fileNo; i++){
        music[i].unmute();
      }
    }
    muted = !muted;
  }
  
  public AudioPlayer getSong(){
    if (currentSongNo >= fileNo){
      return null;
    }
    return music[currentSongNo];
  }
  
  public void close(){
    for (int i = 0; i < fileNo; i++){
      music[i].close();
    }
  }
  
  public void changeSong(int songNo){
    if (music[currentSongNo].isPlaying()){
      music[currentSongNo].pause();
    }
    music[currentSongNo].rewind();
    currentSongNo = songNo;
    if (currentSongNo >= fileNo){
      currentSongNo = 0;
    }
    play();
  }
  
}
class WaveformRenderer implements AudioListener{
  private float[] leftBuffer;
  private float[] rightBuffer;
  float xPos, yPos;
  int barWidth;
  float barHeightModifier = 2;
  int subSampling;

  WaveformRenderer(int bSize) {
    barWidth = bSize;
    subSampling = barWidth/2;
    leftBuffer = null;
    rightBuffer = null;
  }

  public synchronized void samples(float[] newLeftSamples) {
    leftBuffer = newLeftSamples;
  }

  public synchronized void samples(float[] newLeftSamples, float[] newRightSamples) {
    leftBuffer = newLeftSamples;
    rightBuffer = newRightSamples;
  }

  public synchronized void draw() {
    if (leftBuffer == null){
      return;
    }
    noStroke();
    xPos = -(leftBuffer.length/subSampling)*(barWidth/2);
    if ( leftBuffer != null && rightBuffer != null ) {
      for (int sample=0; sample < leftBuffer.length; sample+=subSampling) {
        yPos = 20*leftBuffer[sample];
        fill(255, 100+(abs(yPos)*2));
        rect(xPos, yPos, barWidth, yPos*barHeightModifier);
        xPos+=barWidth;
      }
    }
  }
  
  public float getSample(int sample){
    return leftBuffer[sample];
  }
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Visualiser" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
