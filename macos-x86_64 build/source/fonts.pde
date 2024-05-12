public class FontController{
  int this_codepoint, end_codepoint, scale, restart;
  float x, y;
  char[] chars_uni;
  
  //vars to check & record where the font fails
  ArrayList<Integer> failurePoints = new ArrayList<Integer>();
  Boolean lastFailed = false;
  Boolean failures_latch = false;
  
  public FontController(int start_codepoint, int end_codepoint, float x_pos, float y_pos, int scale){
    this_codepoint = start_codepoint - 1;
    restart = start_codepoint;
    x = x_pos;
    y = y_pos; 
    this.end_codepoint = end_codepoint;
    this.scale = scale;
  }
  
  /* display the rolling unicode icon
     also output the nonfunctional codepoints
  */
  void font_stack_tester() {
    //loop once at the end of testing range
    if(this_codepoint > end_codepoint){
      this_codepoint = restart;
      
      //let this stop once we've hit every codepoint we care about
      if(!failures_latch){
        println("null codepoints: ");
        for(int i = 0; i < failurePoints.size(); i++){
          if(i%2 == 0){
            print("[" + failurePoints.get(i) + ", ");
          } else {
            print(failurePoints.get(i) + "]\n");
          }
        }
      }
      
      failures_latch = true;
    } else {
      this_codepoint++;
    }
    
    //get the char from the codepoint
    chars_uni = (Character.toChars(this_codepoint));
  
    //does this font display it?
    if (default_font.getGlyph(chars_uni[0]) == null){
      stroke(error_colour);
      fill(error_colour);
      
      //is this the first failure of a region?
      if(!lastFailed){
        failurePoints.add(this_codepoint);
        lastFailed = true;
      }
    } else {
      stroke(ui_highlight);
      fill(ui_highlight);
      
      //is this ending a failed region?
      if(lastFailed){
        failurePoints.add(this_codepoint);
        lastFailed = false;
      }
    }
    
    //draw the character
    textSize(scale); 
    rectMode(RADIUS);
    text(new String(chars_uni), x, y + (scale/2.8));
    
    //display the current codepoint
    textSize(14);
    text("U+" + intToUniHex(this_codepoint), x, y + scale*1.4);
    
    //wrap it nice and neat
    fill(0, 0, 0, 0); 
    rect(x, y, scale/1.1, scale/1.1, 10);
  }
  
  //get ranges where current font stack does not have an associated character >>
  //this includes null/whitespace/blank characters that *shouldn't* have an associated character
  void getBrokenRanges(){
    char[] cu_temp;
    Boolean lf_temp = false;
    ArrayList<Integer> fp_temp = new ArrayList<Integer>();
     
     //test for what's broken where, only record start and endpoints of broken ranges
     for(int j = 0; j < end_codepoint+1; j++){
       cu_temp = Character.toChars(j);
       if (default_font.getGlyph(cu_temp[0]) == null && !lf_temp){
          fp_temp.add(j);
          lf_temp = true;
       } else if(default_font.getGlyph(cu_temp[0]) != null && lf_temp){
          fp_temp.add(j);
          lf_temp = false;
       }
     }
     
     //print it all out
     for(int i = 0; i < fp_temp.size(); i++){
       String hexy = intToUniHex(fp_temp.get(i));
       if(i%2 == 0){
         print("[" + hexy + ", ");
       } else {
         print(hexy + "]\n");
       }
     }
  }
  
  //convert an int codepoint to a unicode hexadecimal point
  String intToUniHex(int code){
    String unihex = Integer.toHexString(code);
    while(true){
      if (unihex.length() < 4) {
        unihex = "0" + unihex;
      } else {
        break;
      }
    }
    return unihex.toUpperCase();
  }
}
