@FunctionalInterface
public interface SliderFunction {
  public void execute(Slider s, float pos); 
}

PVector mouse_pressed_position;
void mousePressed(){
  mouse_pressed_position = new PVector(mouseX, mouseY);
}

public class Slider {
  PVector center, set_renderPos, last_renderPos, line_coordsL, line_coordsR;
  float min, max, slope, yincep, horiz, verti;
  String name;
  color[] cols = new color[2]; //base colour, click colour
  Boolean pressed_latch = false;
  SliderFunction func;
  
  //centerpoint, horizontal half distance, vertical half distance, name, starting pos [0, 1], and color pallete
  public Slider(PVector center, float horiz, float verti, String name, float pos, color[] cols, SliderFunction func){
    this.center = center;
    this.horiz = horiz;
    this.verti = verti;
    this.name = name;
    this.cols = cols;
    this.func = func;
    
    set_renderPos = new PVector(horiz*2*pos + (center.x - horiz), verti*2*pos + (center.y - verti));
    last_renderPos = new PVector();
    line_coordsL = new PVector(center.x-horiz, center.y+verti);
    line_coordsR = new PVector(center.x+horiz, center.y-verti);
    slope = (line_coordsL.y - line_coordsR.y) / (line_coordsL.x-line_coordsR.x);
    yincep = line_coordsL.y - slope * line_coordsL.x;
  }
  
  void updatePos(float pos){
    set_renderPos = new PVector(horiz*2*pos + (center.x - horiz), verti*2*pos + (center.y - verti));
  }
  
  void render(){
    manipulate();
    strokeWeight(3);
    
    line(line_coordsL.x, line_coordsL.y, line_coordsR.x, line_coordsR.y);
    circle(center.x-horiz, center.y+verti, 5);
    circle(center.x+horiz, center.y-verti, 5);
    
    circle(set_renderPos.x, set_renderPos.y, 10);
  }
  
  //handle ui interaction
  void manipulate(){
    stroke(cols[1]);
    fill(background_colour);
    
    Boolean was_pressed = pressed_latch;
    
    if(mousePressed){
      PVector nearestPoint = distanceToLine(new PVector(mouseX, mouseY));
      
      if(dist(nearestPoint.x, nearestPoint.y, mouse_pressed_position.x, mouse_pressed_position.y) < 24){   
        pressed_latch = true;
      }
      
      if(pressed_latch){
        set_renderPos.x = nearestPoint.x;
        set_renderPos.y = nearestPoint.y;
        
        last_renderPos.x = nearestPoint.x;
        last_renderPos.y = nearestPoint.y;
        
        stroke(cols[0]);
        fill(cols[0]);
      }
    } else {
      pressed_latch = false;
    }
    
    if(was_pressed && !pressed_latch){
      set_renderPos.x = last_renderPos.x;
      set_renderPos.y = last_renderPos.y;
      
      func.execute(this, this.getPos());
    }
    
  }
  
  //returns nearest point from input point to this slider line
  PVector distanceToLine(PVector point_coords){    
    //modified from solub's (processing forum user) js vector version
    PVector d1 = PVector.sub(line_coordsR, line_coordsL);
    PVector d2 = PVector.sub(point_coords, line_coordsL);
    float l1 = d1.mag();
  
    float dotp = constrain(d2.dot(d1.normalize()), 0, l1);
      
    return PVector.add(line_coordsL, d1.mult(dotp));
  }
  
  float getPos(){
    float percx = (set_renderPos.x - line_coordsL.x) / (horiz*2);
    float percy = (set_renderPos.y - line_coordsL.y) / (verti*2);
    
    if(Float.isNaN(percx)){
      percx = 0;
    } else if(Float.isNaN(percy)){
      percy = 0;
    }
    
    float percies = percx+percy;
    return percies;
  }
}
