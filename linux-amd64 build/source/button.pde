@FunctionalInterface
public interface ButtonFunction {
  public void execute(); 
}

public class Button{
  Boolean pressed, errState;
  PVector loc = new PVector();
  PVector dimens = new PVector();
  String text; 
  ButtonFunction func;
  color[] cols = new color[4]; //fill, stroke, click colour, error colour
  
  //in order: x & y of top left corner, width, height, text to display, colour pallete, this button's associated function, if the button starts with an error state
  public Button(int x, int y, int w, int h, String text, color[] cols, ButtonFunction func, Boolean err){
    loc.x = x;
    loc.y = y;
    dimens.x = w;
    dimens.y = h;
    this.text = text;
    this.cols = cols.clone();
    this.func = func;
    pressed = false;
    errState = err;
  }
  
  //draw and animate the button
  void render(){
    //offset vars controll the 'depress' animation when clicked
    float y_offset = loc.y;
    float height_offset = dimens.y;
    //col vars track how colour pallet inverts based on default, hover, and click
    color stroke_col = cols[1];
    color fill_col = cols[0];
    
    //display error colours
    if(errState == true){
      stroke_col = cols[3];
    }
    
    //hover detection
    if(mouseY > loc.y && mouseY < loc.y+dimens.y && mouseX > loc.x && mouseX < loc.x+dimens.x){
      fill_col = cols[1];
      stroke_col = cols[0];

      //click detection --> triggers if mouse is pressed while hovering over, not just click on the button. need a latch i think to do proper click detection
      if(mousePressed){
        fill_col = cols[2];
        stroke_col = cols[1];
        //depress button
        y_offset += dimens.y/9;
        height_offset -= dimens.y/9;
        
        //flip latch to detect *clicks* not presses
        pressed = true;
      } else {
        run_func();
      }
    }
    
    //draw button
    fill(fill_col);
    stroke(stroke_col);
    rect(loc.x, y_offset, dimens.x, height_offset, 10);
    
    //shift pallette & draw text
    fill(stroke_col);
    stroke(fill_col);
    text_display(y_offset);
  }
  
  //draw text within region, animate accordingly
  void text_display(float y_offset){
    textSize(dimens.y - dimens.y/9 - 2);
    //will not draw text outside specified region
    textAlign(CENTER);
    text(text, loc.x + dimens.y/8, y_offset + dimens.y/8, dimens.x - dimens.y/8, dimens.y - dimens.y/8);
  }
  
  //run buttonfunctions associated with the button pressed
  void run_func(){
    if(pressed){
      func.execute();
      pressed = false;
    }
  }
  
  void setFunc(ButtonFunction funky){
    func = funky;
  }
  
  //setopacity short for "void setopacity float-alpha" would be a beautiful name for a baby girl
  void setOpacity(float alpha){
    cols[0] = color(red(cols[0]), green(cols[0]), blue(cols[0]), alpha);
    cols[1] = color(red(cols[1]), green(cols[1]), blue(cols[1]), alpha);
    cols[2] = color(red(cols[2]), green(cols[2]), blue(cols[2]), alpha);
    cols[3] = color(red(cols[3]), green(cols[3]), blue(cols[3]), alpha);
  }
  
  //set the error display state
  void setError(Boolean err){
    errState  = err;
  }
  
  //get the error display state
  Boolean getError(){
    return errState;
  }
  
  //alter string displayed on button
  void setName(String newName){
    text = newName;
  }
  
  String getName(){
    return text;
  }
}
