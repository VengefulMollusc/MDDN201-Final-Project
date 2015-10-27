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

  synchronized void samples(float[] newLeftSamples) {
    leftBuffer = newLeftSamples;
  }

  synchronized void samples(float[] newLeftSamples, float[] newRightSamples) {
    leftBuffer = newLeftSamples;
    rightBuffer = newRightSamples;
  }

  synchronized void draw() {
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
  
  float getSample(int sample){
    return leftBuffer[sample];
  }
}
