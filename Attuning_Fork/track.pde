//processing video library throws errors on archlinux systems
//  >> problem with dual dependancy on libsoup 2 & 3
//     for now, no video implementation. maybe eventually
//      > will need to document how to resolve on archlinux systems in git page
//import processing.video.*;
//Movie movie;

import ddf.minim.*;

//second processing window --> like an entire sub-sketch
public class DisplayFrame extends PApplet {
  Minim minim;
  Track track_controller;

  public void settings() {
    size(int(default_scale.y/2), int(default_scale.x/2));
  }

  public void setup() {
    minim = new Minim(this);
    surface.setTitle("track display");
    track_controller = new Track();
    surface.setLocation(int(displayWidth-default_scale.y/2) - 50, 100);
  }

  public void draw() {
    background(background_colour);

    track_controller.displayMetadata();
    track_controller.loadTrack();
  }

  void exit() {
    systemControlButtons.set(5, spawn_window);
    dispose();
    sa = null;
  }

  void playButton() {
    track_controller.pauseResume();
  }

  void restartAudioVideo() {
    track_controller.restartAudio();
  }

  void fastforward(int milli) {
    track_controller.fastforward(milli);
  }

  Boolean getIsPlaying() {
    return track_controller.tuneIsPlaying();
  }

  int getTimeMillis() {
    if (track_controller == null) {
      track_controller = new Track();
    }
    return track_controller.getTimestamp();
  }

  void setTime(int milli) {
    if (track_controller != null) {
      track_controller.setTimestamp(milli);
    }
  }

  float getTime() {
    if (track_controller != null) {
      return track_controller.getDuration();
    }
    return 0;
  }

  void setVol(float vol) {
    if (track_controller != null) {
      track_controller.setVol(vol);
    }
  }
  
  String getMeta(int i){
    if (track_controller != null){
      return track_controller.getMetaData(i);
    }
    return "";
  }

  public class Track {
    //WaveformRenderer waveform; --> on the minim addListener() documentation, this is a custom class. maybe implement for polish later!
    AudioPlayer tune;
    AudioMetaData tune_meta;

    public Track() {
      loadTrack();
    }

    void restartAudio() {
      if (tune != null) {
        tune.cue(0);
      }
    }

    void fastforward(int milli) {
      if (tune != null) {
        tune.skip(milli);
      }
    }

    void setTimestamp(int milli) {
      if (tune != null) {
        tune.cue(milli);
      }
    }

    void setVol(float vol) {
      if (tune != null) {
        tune.shiftVolume(vol, tune.getVolume(), 500);
        tune.shiftGain(tune.getGain(), vol*100-50, 500);
        println("vol=" + vol);
      }
    }

    void displayMetadata() {
      if (tune == null) {
        return;
      }

      fill(ui_highlight);

      textSize(15);
      text(tune_meta.fileName(), 10, 20);

      textSize(40);
      text(tune_meta.title(), 30, 70);
      textSize(30);
      text("by " + tune_meta.author(), 45, 110);

      textSize(20);
      text("on the album \"" + tune_meta.album() + "\"", 60, 145);

      textSize(70);
      text("duration:  ~" + getFormatedTimecode(tune_meta.length(), true, ':', false, ' '), 45, 260);
    }

    //0 outputs title, 1 outputs author
    String getMetaData(int i){
      if (tune == null){
        return "";
      } else if (i == 0){
        return tune_meta.title();
      } else if (i == 1){
        return tune_meta.author();
      }
      return "";
    }

    int getDuration() {
      if (tune != null && tune_meta != null) {
        return tune_meta.length();
      }
      return 1;
    }

    void loadTrack() {
      if (tune == null && track != null) {
        tune = minim.loadFile(track.getAbsolutePath());
        tune_meta = tune.getMetaData();
      }
    }

    void pauseResume() {
      if (tune != null) {
        if (tune.isPlaying()) {
          tune.pause();
        } else {
          tune.play();
        }
      }
    }

    Boolean tuneIsPlaying() {
      if (tune != null) {
        return tune.isPlaying();
      }
      return false;
    }

    int getTimestamp() {
      if (tune != null) {
        return tune.position();
      }
      return 0;
    }
  }
}
