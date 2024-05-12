import java.awt.*;
import java.io.*;
import java.util.*; 
import javax.swing.*;

DisplayFrame sa;
PopoutMenu outputSelectMenu;

PVector default_scale = new PVector(900, 1400);
PImage volIcon;

PFont default_font;
String[] font_tester;
//highest unicode codepoint is 289460
int highest_codepoint = 289460;
FontController font_controls = new FontController(0, highest_codepoint, 900-55, 120, 40);

Transcript trans;
Boolean is_transcript;
File track, transcript, outputDirectory;
String outputExtention = "";

//colour scheme of the whole program
color background_colour = color(76, 56, 76);
color ui_background = color(11, 57, 84);
color ui_active = color(232, 232, 232);
color ui_highlight = color(129, 198, 239);
color error_colour = color(252, 129, 74);
color[] buttonCols = {ui_background, ui_highlight, ui_active, error_colour};
color[] sliderCols = {ui_active, ui_highlight};
color[] menuCols = {ui_background, error_colour};

//num of millis to skip when fastforward or reversing
int skipMillis = 500;

ButtonFunction placeholder_func = () -> println("this is a placeholder function");

ButtonFunction saveTranscript = () -> {
  saveButtonControl();
};

ButtonFunction spawnWindow = () -> {
  if(sa == null){
    String[] args = {"track info"};
    sa = new DisplayFrame();
    runSketch(args, sa);
    removeButton(5);
  }
};

ButtonFunction chooseTrack = () -> {
  is_transcript = false;
  selectInput("Select a track to play:", "chooseFile");
  spawnWindow.execute();
};

ButtonFunction chooseTranscript = () -> {
  is_transcript = true;
  selectInput("Select a transcript to sync:", "chooseFile");
};

ButtonFunction chooseOutputDir = () -> {
  selectFolder("Select output directory:", "chooseDirectory");
};

ButtonFunction chooseOutputForm = () -> {
  outputSelectMenu.toggleMenu();
};

ButtonFunction restartButton = () -> {
  if(sa != null){
    sa.restartAudioVideo();
  }
  if(trans != null){
    trans.resetTranscript();
  }
};

ButtonFunction reverseButton = () -> {
  if(sa != null){
    sa.fastforward(-skipMillis*40);
  }
};

ButtonFunction ffButton = () -> {
  if(sa != null){
    sa.fastforward(skipMillis);
  }
};

ButtonFunction pauseButton = () -> {
  if(sa != null){
    sa.playButton();
  }
  setPauseButtonName();
};

SliderFunction timelineSliderSkip = (Slider self, float pos) -> {
  if(sa != null){
    float newPos = self.getPos();
    self.updatePos(newPos);
    sa.setTime(int(newPos * sa.getTime()));
  }
};
 
SliderFunction volumeSlider = (Slider self, float pos) -> {
  if(sa != null){  
    sa.setVol(-pos -1);
    println(-pos -1);
  }
};
 
ArrayList<Button> systemControlButtons = new ArrayList<Button>();
  Button save_trans   =      new Button(20,  10, 35,  30, str('\u2193'),          buttonCols, saveTranscript,   true);
  Button select_track =      new Button(65,  10, 75,  30, "track",                buttonCols, chooseTrack,      true);
  Button select_transcript = new Button(150, 10, 135, 30, "transcript",           buttonCols, chooseTranscript, true);
  Button change_output_dir = new Button(295, 10, 235, 30, "output directory",     buttonCols, chooseOutputDir,  true);
  Button change_out_format = new Button(540, 10, 65,  30, "???",                  buttonCols, chooseOutputForm, true);
  Button spawn_window =      new Button(int(default_scale.x-55), 10, 35, 30, str('\u23cf'), buttonCols, spawnWindow,      false);
  
ArrayList<Button> trackControlButtons = new ArrayList<Button>();
  Button restart_button = new Button(int(default_scale.x-255), 10, 35, 30, str('\u23EE'), buttonCols, restartButton, false);
  Button reverse_button = new Button(int(default_scale.x-205), 10, 35, 30, str('\u23EA'), buttonCols, reverseButton, false);
  Button pause_button =   new Button(int(default_scale.x-155), 7,  40, 33, "▶",           buttonCols, pauseButton,   false);
  Button ff_button =      new Button(int(default_scale.x-105), 10, 35, 30, str('\u23E9'), buttonCols, ffButton,      false);


//lrc, sbv, smi, sami, srt, txt, vtt, [none]
ArrayList<Button> filetypeSelectionButtons = new ArrayList<Button>();
  Button select_lrc = new Button (367, 100, 65, 30, "lrc", buttonCols, placeholder_func, true);
  Button select_sbv = new Button (444, 100, 65, 30, "sbv", buttonCols, placeholder_func, true);
  Button select_smi = new Button (523, 100, 65, 30, "smi", buttonCols, placeholder_func, true);
  
  Button select_sami= new Button (367, 143, 65, 30, "sami", buttonCols, placeholder_func, true);
  Button select_srt = new Button (444, 143, 65, 30, "srt", buttonCols, placeholder_func, true);
  Button select_txt = new Button (523, 143, 65, 30, "txt",buttonCols, placeholder_func, true);
  
  Button select_vtt = new Button (367, 186, 65, 30, "vtt", buttonCols, placeholder_func, true);
  
  Button select_none= new Button (367, 272, 221, 30, "NONE", buttonCols, placeholder_func, true);

ButtonFunction sLRC = () -> updateFSButtons(select_lrc);
ButtonFunction sSRT = () -> updateFSButtons(select_srt);
ButtonFunction sSBV = () -> updateFSButtons(select_sbv);

ButtonFunction sVTT = () -> updateFSButtons(select_vtt);
ButtonFunction sSMI = () -> updateFSButtons(select_smi);
ButtonFunction sSAMI= () -> updateFSButtons(select_sami);

ButtonFunction sTXT = () -> updateFSButtons(select_txt);

ButtonFunction sNONE= () -> updateFSButtons(select_none);

ArrayList<Slider> mediaControlSliders = new ArrayList<Slider>();
  Slider volume   = new Slider(new PVector(int(default_scale.x-35), 264), 0, 100, "volume",   .5, sliderCols, volumeSlider);
  Slider timeline = new Slider(new PVector(int(default_scale.x-135), 64), 100, 0, "timeline", .5, sliderCols, timelineSliderSkip);

void updateFSButtons(Button thisButton){
  String exten = thisButton.getName();
  
  if(exten.equals("NONE")){
    outputExtention = "";
    change_out_format.setName("N/A");
  } else {
    outputExtention = "." + exten;
    change_out_format.setName(exten);
  }
  filetypeSelectionButtons.forEach((b) -> b.setError(true));
  thisButton.setError(false);
  change_out_format.setError(false);
}

void removeButton(int i){
  Button blank_button = new Button(-1000, -1000, 4, 4, "", buttonCols, placeholder_func, false);
  systemControlButtons.set(i, blank_button);
}

void setPauseButtonName(){
  if(sa != null && sa.getIsPlaying()){
    pause_button.setName(str('\u23F8'));
  } else {
    pause_button.setName("▶");
  }
}

void setDirButtonName(){
  if(outputDirectory != null){
    change_output_dir.setName(outputDirectory.getName());
  }
}

void saveButtonControl(){
  if(save_trans.getError()){
    return;
  }
  trans.saveTranscript();
}

/*
void settings() {
  size(int(default_scale.x), int(default_scale.y));
}
*/

void setup(){
  select_lrc.setFunc(sLRC);
  select_srt.setFunc(sSRT);
  select_sbv.setFunc(sSBV);
  
  select_vtt.setFunc(sVTT);
  select_smi.setFunc(sSMI);
  select_sami.setFunc(sSAMI);
  
  select_txt.setFunc(sTXT);
  
  select_none.setFunc(sNONE);
  
  filetypeSelectionButtons.add(select_lrc);
  filetypeSelectionButtons.add(select_srt);
  filetypeSelectionButtons.add(select_sbv);
  
  filetypeSelectionButtons.add(select_vtt);
  filetypeSelectionButtons.add(select_smi);
  filetypeSelectionButtons.add(select_sami);
  
  filetypeSelectionButtons.add(select_txt);
  
  filetypeSelectionButtons.add(select_none);
  
  int scale_adjust = 0;
  PVector filetypeMenuLoc = new PVector(477, 190 + (scale_adjust/2));
  PVector filetypeMenuDim = new PVector(260, 270 + scale_adjust);
  outputSelectMenu = new PopoutMenu("select output format", menuCols, filetypeMenuLoc, filetypeMenuDim, filetypeSelectionButtons); 

  //this is not an existant font, so processing defaults to system fonts for any unicode
  default_font = createFont("getting system fonts - this error is expected", 20);
  textFont(default_font);
  
  //font_controls.getBrokenRanges();
  //font_tester = loadStrings("font_chars_tester.txt");
  trans = new Transcript(new String[] {" "});

  systemControlButtons.add(save_trans);
  systemControlButtons.add(select_track);
  systemControlButtons.add(select_transcript);
  systemControlButtons.add(change_output_dir);
  systemControlButtons.add(change_out_format);
  systemControlButtons.add(spawn_window);
  
  trackControlButtons.add(pause_button);
  trackControlButtons.add(ff_button);
  trackControlButtons.add(reverse_button);
  trackControlButtons.add(restart_button);
  
  mediaControlSliders.add(volume);
  mediaControlSliders.add(timeline);
  
  size(900, 1400);
  surface.setTitle("transcript");
  surface.setResizable(true);
  surface.setLocation(displayWidth/2 - int(default_scale.x/1.5), displayHeight/2 - int(default_scale.y/2));
  
  volIcon = loadImage("volume.png");
}

void draw(){
  background(background_colour);
  defaultDrawing();
  
  //update the transcript on the page, transcript related hotkeys
  //drawn early to avoid overlapping the buttons and controls
  if(trans != null){
    trans.update();
  }

  if(sa != null){
    timeline.updatePos(sa.getTimeMillis() / sa.getTime());
  }
  
  //render core system buttons & implement functionalities
  systemControlButtons.forEach((b) -> b.render());
  trackControlButtons.forEach((t) -> t.render());
  mediaControlSliders.forEach((m) -> m.render());
  outputSelectMenu.renderMenu();

  pushMatrix();
  translate(875, 210);
  textSize(20);
  rotate(radians(90));
  fill(ui_active);
  text("volume", 0, 0);
  popMatrix();

  //display the font tester rolling over every unicode display
  //font_controls.font_stack_tester();
}

//combined func for selecting transcript and track files, yucky because of buttonfunction nonsense
void chooseFile(File selection) {
  if(selection == null){
    println("no file selected!");
  } else {
    String filename = selection.getName();
    int i = filename.lastIndexOf('.');
    String extention = "";
    
    //get file extention
    if(i == -1){
      println("this file has no extention!");
    } else {
      extention = filename.substring(i+1);
    }
    
    //switch which file is defined based on button press
    if(is_transcript){
      
      transcript = selection;
      select_transcript.setError(false);
      
      if(!change_output_dir.getError()){
        save_trans.setError(false);
      }
      
      if(extention.equals("")){
        change_out_format.setName("N/A");
      } else if (outputExtention.equals("")){
        change_out_format.setName("." + extention);
        outputExtention = "." + extention;
      }
      change_out_format.setError(false);
      
      trans = new Transcript(loadStrings(transcript));

    } else if(extention.equals("mp3") || extention.equals("wav") || extention.equals("snd") || extention.equals("au") || extention.equals("aiff")){        
      track = selection;
      select_track.setError(false);
    } else {
      println("incompatable filetype! Track must be mp3, wav, snd, au, or aiff!");
    }
  }
}

void chooseDirectory(File selection){
  if(selection == null){
    println("no directory selected!");
  } else {
    outputDirectory = selection;
    setDirButtonName();
    change_output_dir.setError(false);
    
    if(!select_transcript.getError()){
      save_trans.setError(false);
    }
  }
}

// resent default drawing modes
void defaultDrawing(){
  strokeWeight(3);
  rectMode(CORNER);
}

//input a time in milliseconds, output converted timecode info
//handles format as an array of ints, rather than a string, so that
//place information, leading zeroes and whatnot are preserved
//and is readable at the same time, without gross %f shit
//                         millis   include hours  HH?MM?SS        include hundreths  SS?HHH
String getFormatedTimecode(int mil, Boolean hours, char delimiter, Boolean hundreths, char fractionals){
  String formatted_timecode = "";
  
  //manipulate non-hundrets by secs/min/hours to deal with rollover @ 60
  int secs = mil/1000; 
  int mins = secs/60;  
  int hrs  = mins/60;
  
  //need to do this for accurate 10s places
  secs = secs-(mins*60); 
  
  //hours
  if(hours){
    //need to do this for conditional formatting for hours inclusion
    mins = mins-(hrs*60);
    
    formatted_timecode += hrs/10 + str(hrs%10) + delimiter; //even handles the event there are >99 hours!
  }
  
  //minutes
  formatted_timecode += mins/10 + str(mins%10) + delimiter; //handles hourless cases with >60 minutes!

  //seconds 
  formatted_timecode += secs/10 + str(secs%10);

  //thousanths, hundreths, and tenths
  //not pre-formatted as secs, mins, & hrs are, hence % / mixing
  if(hundreths){
    formatted_timecode += fractionals + str((mil%1000)/100) + str((mil%100)/10) + mil%10;
  }
  
  return formatted_timecode;
}
