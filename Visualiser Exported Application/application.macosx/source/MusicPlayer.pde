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
  
  void loadMusic(WaveformRenderer waveform){
    for (int i = 0; i < fileNo; i++){
      music[i] = minim.loadFile("song" + i + ".mp3");
    }
    
    for (int i = 0; i < fileNo; i++){
      music[i].addListener(waveform);
    }
  }
  
  void update(){
    if (currentSongNo >= fileNo){
      return;
    }
    if (!music[currentSongNo].isPlaying() && !paused){
      playNext();
    }
  }
  
  void play(){
    if (currentSongNo >= fileNo){
      return;
    }
    music[currentSongNo].play();
    meta = music[currentSongNo].getMetaData();
  }
  
  void playPause(){
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
  
  void playNext(){
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
  
  void mute(){
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
  
  AudioPlayer getSong(){
    if (currentSongNo >= fileNo){
      return null;
    }
    return music[currentSongNo];
  }
  
  void close(){
    for (int i = 0; i < fileNo; i++){
      music[i].close();
    }
  }
  
  void changeSong(int songNo){
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
