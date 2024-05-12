/* store transcript as a string array trans
display it >> account for scrolling. scroll using scroll wheel dynamically. 
'jump to next/prev line' in display
link text to vertical timeline >> variable spacing on timeline based on a slider/adjustment bar like in kdenlive
let you click on spots on vertical timeline to jump to position on scroll
dot indicators for where text appears in the vertical scroll --> if two texts would overlap, low opacity the further away text is from current pos
hotkey to advance lyric and record a position, hotkey to go back to last lyric AND unbind its position

allow when music is paused click & drag of lyric positions within the rang of prev & following lyric
*/

public class Transcript{
  char last_key; // remember last key pressed, for hotkey behavior
  int last_millis = 0; // remember time of hotkey press, for hotkey behavior
  int hotkey_millis_delay = 800; // delay between pressing the hotkey and triggering mode 2
  
  // this could be implemented better via an arraylist of tuples
  ArrayList<String> trans = new ArrayList<String>(); // the transcript
  ArrayList<Integer> times = new ArrayList<Integer>(); // the corresponding times for each line --> initialized as 0
  ArrayList<Boolean> toggles = new ArrayList<Boolean>(); // and the toggles for enabled/disabled lines --> initialized as true
  
  Boolean is_offscreen = false; // current line is offscreen = true
  int current_line; // index in trans of the currently selected line
  int line_spacing = 35; // spacing between lines, also used in other positionings on the screen
  float time_width = textWidth("0:00:00"); // because we need this regularly :p
  int timestamp = 0;
  
  float scroll = line_spacing*3; // the initial position of text on screen
  float scroll_speed = 13.4; // scroll multiplier
  
  int trans_size = 20; // size of the text in the transcript
  color default_text_color = ui_active; // the default colour of the tex
  color highlight_text_color = ui_highlight; // the colour of the selected line
  
  public Transcript(String[] trans){
    this.trans = new ArrayList(Arrays.asList(trans));
    this.trans.add(0, "");
    this.trans.add("");
    
    this.trans.forEach(t -> {times.add(0); toggles.add(true);}); // fill out times/toggles so we can keep the arraylists synced
  }
  
  //display this transcript, then listen for all transcript-based hotkeys
  void update(){
    if(track != null && sa != null){
      timestamp = sa.getTimeMillis();
    }
    
    display();
    
    // nextline [enter]
    if(hotkey(ENTER, 1, false)){
      current_line++;
      
      times.set(current_line-1, timestamp);
      
      offscreenOffset();
      
      if(current_line > trans.size()-1){
        current_line = trans.size()-1;
      } 
    }
    
    // prevline [backspace]
    else if (hotkey(BACKSPACE, 1, false)){
      times.set(current_line, 0);
      current_line--;
      
      if(current_line < 0){
        current_line = 0;
      }
      
      if(track != null && sa != null){
        sa.setTime(times.get(current_line));
      }
      
    } 
    
    // insert blank [tab]
    else if (hotkey(TAB, 0, false)){    
      current_line++;
      trans.add(current_line, "");
      times.add(current_line, millis());
      toggles.add(current_line, true);
    } 
    
    // [t]oggle line enabling
    else if (hotkey('t', 0, false)){
      toggles.set(current_line, !toggles.get(current_line));
    }
    
    // [delete] blank line
    else if (hotkey(DELETE, 0, false)){
      if(trans.get(current_line) == ""){
        trans.remove(current_line);
        toggles.remove(current_line);
        times.remove(current_line);
        current_line--;;
        
        if(current_line < 0){
          current_line = 0;
        }
      }
    }
      
    // [space] play/pause audio 
    else if (hotkey(' ', 0, false)){
      pauseButton.execute();
    }
    
    // [r]estart track
    else if (hotkey('r', 0, false)){
      restartButton.execute();
    }
    
    // rewind & fast farward
    else if (key == CODED){
      
      // [right arrow] fast forward
      if (keyCode == RIGHT && hotkey('\u0001', 2, true)){
        ffButton.execute();
      }
      
      // [left arrow] rewind
      if(keyCode == LEFT && hotkey('\u0000', 2, true)){
        reverseButton.execute();
      }
    }
    
    if(scroll > line_spacing*(3+current_line)){
      scroll = line_spacing*(3+current_line);
    }
  }
  
  /* sets the display parameters
  and then draws the transcript! */
  void display(){
    textSize(trans_size);
    
    drawVisibleLines(default_text_color);
    drawCurrentLine(highlight_text_color);

    fill(background_colour);
    stroke(0, 0, 0, 0);
    rect(0, 0, width, 50);
  }
  
  //draws lines within the window
  void drawVisibleLines(color line_colour){
    color this_line_colour;
    float linePos;
    
    for(int i = 0; i < trans.size(); i++){
      linePos = (i-current_line) * line_spacing + scroll;
      //stop looping if we're drawing past the bottom of the screen!
      if(linePos > height){
        break;
      } 
      
      //draw all non-current characters within the top of the window
      else if (linePos > 0 && i != current_line){
        
        if(!toggles.get(i)){
          this_line_colour = color(line_colour, 70);
        } else {
          this_line_colour = line_colour;
        }
        fill(this_line_colour);
        text(trans.get(i), width/2, linePos);
        
        stroke(0, 0, 0, 0);
        fill(background_colour);
        rect(line_spacing*1.5-time_width/2 - 10, linePos+10-line_spacing, time_width + 20, 36);
        
        fill(this_line_colour);
        stroke(this_line_colour);
        text(getFormatedTimecode(times.get(i), true, ':', false, '.'), line_spacing*1.3, linePos);
        
        if(i < current_line){
          strokeWeight(5);
          stroke(color (this_line_colour, 70));
          line(line_spacing+time_width, linePos - trans_size/3, width/2 - textWidth(trans.get(i))/2 - 10, linePos - trans_size/4);
          strokeWeight(4);
          
          if(trans.get(i) == ""){
            text("●", width/2, linePos);
          }
        }
      }
    }
  }
  
  //draws current line, handles off-screen behavior
  void drawCurrentLine(color line_colour){
    is_offscreen = true;
    String cur_line = trans.get(current_line);
    String thisTime = getFormatedTimecode(timestamp, true, ':', true, '.').substring(0, 10);
    float currentPos = scroll - line_spacing;
    float txt_width = textWidth(cur_line);
    float time_width = textWidth(thisTime);
    
    if(currentPos <= line_spacing*2){
      currentPos = line_spacing*2;
    } else if (currentPos >= height-line_spacing*2){
      currentPos = height-line_spacing*2;
    } else {
      is_offscreen = false;
    }
    
    if(!toggles.get(current_line)){
      line_colour = color(line_colour, 100);
    }
    
    stroke(line_colour);
    fill(background_colour);
    rect(width/2 - txt_width/2 - 10, currentPos+10, txt_width + 20, 36);
    rect(line_spacing*1.5-time_width/2 - 10, currentPos+10, time_width + 20, 36);
    
    fill(line_colour);
    text(cur_line, width/2, currentPos+line_spacing);
    text(thisTime, line_spacing*1.5, currentPos+line_spacing);
  }
  
  //when is offscreen, this will offset autoscrolling. called in hotkey funcs
  void offscreenOffset(){
    if(is_offscreen){
      scroll += line_spacing;
    }
  }
  
  /* returns true if input char = just pressed char. held down char activates only once.
  'mode' changes this behavior 
    --> 0 = one output per press; 1 = wait before repeat output; 2 = one output per frame
  if a char A is held, and the char B = hot, then func will return true. 
  if after pressing B, A remains held, future presses of B will return false. This is a bug. */
  Boolean hotkey(char hot, int mode, Boolean forceRun){ 
    //in modes 1 & 2, higher val here = slower output there
    int slow_val = 3;
    
    //check if any key is pressed
    if(!keyPressed){
      last_key = '\u0000';
      return false;
    } 
    
    //correct key?
    if(key != hot && !forceRun){
      return false;
    }
    
    //if the key is being held, mode behavior
    if(key == last_key){
      int mils = millis();
      
      if(mode == 0){ return false; } 
      
      //if not enough time between initial and present press, mills%slow to slow down output
      if(mode == 1 && (last_millis + hotkey_millis_delay > mils || mils % slow_val != 0)){ return false; }
      
      //the mills%slow part just slows down mode 2's rate of output
      if(mode == 2 && mils % slow_val != 0){ return false; }
      
    } else {
      last_millis = millis();
    }
    
    last_key = hot;
    return true;
  }
  
  //basic scroll behavior
  void scroll_page(int sc){
    scroll -= sc*scroll_speed;
    
    if(scroll > line_spacing*(3+current_line)){
      scroll = line_spacing*(3+current_line);
    }
  }
  
  //in the name, it resets transcript position without reseting programmed values
  void resetTranscript(){
    scroll = line_spacing*3;
    current_line = 0;
  }
  
  //called to save transcript to a file, based on user filetype selection
  //formats: lrc, srt, sbv, mpsub, cap, smi, sami, vtt, ttml, dfxp, scc, stl, tds, cin, asc, ass, ssa, txt
  //          1    1    1     0     0    1    1     1     0     0    0    0    0    0    0    0    0    1
  void saveTranscript(){
    //if nowhere to output
    if(outputDirectory == null){
      println("invalid or null output directory!");
      return;
    }
    
    println("Sending to file...");
    ArrayList<String> trans_final = new ArrayList<String>();
    switch(outputExtention){
      case ".lrc":
        trans_final = format_lrc();
        break;
      case ".srt":
        trans_final = format_srt();
        break;
      case ".sbv":
        trans_final = format_sbv();
        break;
      case ".smi":
        trans_final = format_sami();
        break;
      case ".sami":
        trans_final = format_sami();
        break;
      case ".vtt":
        trans_final = format_vtt();
        break;
      case ".txt":
        trans_final = format_txt();
        break;
      case "":
        trans_final = format_txt();
        break;
      default:
        trans_final = format_txt();
        break;
    }
    
    trans_final.forEach((l) -> println(l));
    saveTransToFile(trans_final);
  }
  
  void saveTransToFile(ArrayList<String> transie){
    try{
      String fileNamePath = outputDirectory.getAbsolutePath() + "/" + transcript.getName().replaceFirst("[.][^.]+$", "") + "_sync" + outputExtention;
      File myObj = new File(fileNamePath);
      println(myObj.getAbsolutePath());
      if (myObj.createNewFile()) {
        System.out.println("File created: " + myObj.getName());
        try {
          FileWriter myWriter = new FileWriter(fileNamePath);
          
          for(int i = 0; i < transie.size(); i++){
            myWriter.write(transie.get(i)+"\n");
          }
          myWriter.close();
          System.out.println("Successfully wrote modified transcript to file!");
        } catch (IOException e) {
          System.out.println("Unexpected error occurred while writing to file");
          e.printStackTrace();
        }
        
      } else {
        System.out.println("An unexpected exporting occured. File already exists? Data will not be overwritten.");
      }
    } catch (IOException e){
      System.out.println("Unexpected error occured during file creation");
      e.printStackTrace();
    }
  }
  
  //format the transcript info into lrc style
  ArrayList<String> format_lrc(){
    ArrayList<String> lrc = new ArrayList<String>();
    
    if(sa != null){
      lrc.add("[ti:" + sa.getMeta(0) + "]");
      lrc.add(" [ar:" + sa.getMeta(1) + "]");
    }
    for(int i = 0; i < trans.size(); i++){
      if(toggles.get(i)){
        lrc.add(getFormatedTimecode(times.get(i), false, ':', true, '.') + " " + trans.get(i));
      }
    }
    
    return lrc;
  }
  
  //format the transcript to srt
  ArrayList<String> format_srt(){
    ArrayList<String>lrc = new ArrayList<String>();
    int count = 1;
    
    if(sa != null){
      times.add(int(sa.getTime()));
    } else {
      times.add(0);
    }
    
    for(int i = 0; i < trans.size(); i++){
      if(toggles.get(i)){
        lrc.add(str(count));
        lrc.add(getFormatedTimecode(times.get(i), true, ':', true, ',') + " --> " + 
                getFormatedTimecode(times.get(i+1), true, ':', true, ','));
        
        lrc.add(trans.get(i));
        lrc.add("");
        count++;
      }
    }
    
    return lrc;
  }
  
  //format the transcript to sbv 
  ArrayList<String> format_sbv(){
    ArrayList<String>lrc = new ArrayList<String>();
    
    if(sa != null){
      times.add(int(sa.getTime()));
    } else {
      times.add(0);
    }
    
    for(int i = 0; i < trans.size(); i++){
      if(toggles.get(i)){
        lrc.add(getFormatedTimecode(times.get(i), true, ':', true, '.').substring(1) + "," + 
                getFormatedTimecode(times.get(i+1), true, ':', true, '.').substring(1));
        
        lrc.add(trans.get(i));
        lrc.add("");
      }
    }
    
    return lrc;
  }
  
  ArrayList<String> format_vtt(){
    ArrayList<String>lrc = new ArrayList<String>(Arrays.asList(
    "WEBVTT",
    "STYLE",
    "::cue {",
    "    font-family: Arial;",
    "    color: fff;",
    "}"
    ));
    
    int count = 1;
    
    if(sa != null){
      times.add(int(sa.getTime()));
    } else {
      times.add(0);
    }

    for(int i = 0; i < trans.size(); i++){
      if(toggles.get(i)){
        lrc.add(str(count));
        lrc.add(getFormatedTimecode(times.get(i), true, ':', true, '.').substring(1) + " --> " + 
                getFormatedTimecode(times.get(i+1), true, ':', true, '.').substring(1));
        
        lrc.add(trans.get(i));
        lrc.add("");
        count++;
      }
    }   
 
    return lrc;
  }
  
  //TODO: lang coded into standard, so outputs will be labled as "english" even if not
  //lang selection ability for outputs? workarounds?
  ArrayList<String> format_sami(){
    ArrayList<String>lrc = new ArrayList<String>(Arrays.asList(
    "<SAMI>",
    "",
    "<HEAD>",
    "<TITLE>SAMI Example</TITLE>",
    "",
    "<SAMIParam>",
    "  Media {cheap44.wav}",
    "  Metrics {time:ms;}",
    "  Spec {MSFT:1.0;}",
    "</SAMIParam>",
    "",
    "<STYLE TYPE=\"text/css\">",
    "<!--",
    "  P { font-family: Arial; font-weight: normal; color: white; background-color: black; text-align: center; }",
    "",
    "  #Source {color: red; background-color: blue; font-family: Courier; font-size: 12pt; font-weight: normal; text-align: left; }",
    "",
    "  .ENUSCC { name: English; lang: en-US ; SAMIType: CC ; }",//language denotation is inherent in the standard. currently the user cannot select language, so. this will do.
    "-->",
    "</STYLE>",
    "",
    "</HEAD>",
    "",
    "<BODY>",
    "",
    "<!-- Open play menu, choose Captions and Subtiles, On if available -->",
    "<!-- Open tools menu, Security, Show local captions when present -->",
    ""
    ));
    
    for(int i = 0; i < trans.size(); i++){
      if(toggles.get(i)){
        lrc.add("<SYNC Start=" + times.get(i) + ">");
        lrc.add("  <P Class=ENUSCC>" + trans.get(i) + "</P>");
        lrc.add("</SYNC>");
        lrc.add("");
      }
    }   
    
    lrc.add("</BODY>");
    lrc.add("</SAMI>");

    return lrc;
  }
  
  ArrayList<String> format_txt(){
    ArrayList<String>lrc = new ArrayList<String>(Arrays.asList(
    "<<LYRICAL OUTPUT>>",
    "format: [toggled?] [millis] | text",
    "",
    "----------------------------------------------",
    ""
    ));
    
    for(int i = 0; i < trans.size(); i++){
      lrc.add("[" + toggles.get(i) + "] [" + times.get(i) + "] | " + trans.get(i));
    }   
    
    return lrc;
  }
}

void mouseWheel(MouseEvent event){
  trans.scroll_page(event.getCount());
}
