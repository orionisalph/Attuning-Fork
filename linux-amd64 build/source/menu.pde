public class PopoutMenu{
  PVector center, dimens;
  String title;
  ArrayList<Button> menuButtons;
  
  color[] cols = new color[2]; //0 = background, 1 = outline & text
  
  int titleTextSize = 40;
  
  Boolean closed = true;
  int animationDur = 20;
  int animationState = 0;
  
  
  //initialize with title, cols, center of menu, dimentions, and the buttons to display
  public PopoutMenu(String title, color[] cols, PVector center, PVector dimens, ArrayList<Button> buttons){
    this.title = title;
    this.cols = cols;
    this.center = center;
    this.dimens = dimens;
    menuButtons = buttons;
  }
  
  //for bringing up and closing the menu
  void toggleMenu(){
    closed = !closed;
    animationState = 0;
  }
  
  //if menu is open, animate & render it!
  void renderMenu(){
    //translate(center.x-(dimens.x/2), center.y-(dimens.y/2));
    rectMode(CENTER);
    if(closed){
      return;
    }
    //temp dimensions to animate
    float dimx = dimens.x;
    float dimy = dimens.y;
    float fillAlpha = 255;
    
    if(animationState < animationDur){
      float halfway = animationDur/2;
      
      //first half of animation, pop in menu
      if(animationState < halfway){
        dimx *= animationState/halfway;
        dimy *= animationState/halfway;

        menuButtons.forEach((b) -> b.setOpacity(0));
        fillAlpha = 0;
        
      //second half of animation, fade in buttons
      } else {
        fillAlpha = 255 * (animationState-halfway)/halfway;
        menuButtons.forEach((b) -> b.setOpacity(255 * (animationState-halfway)/halfway));
      }
      
      animationState++;
    }
      
    //draw background & text, then draw buttons & reset drawing mode
    fill(cols[0]);
    stroke(cols[1]);
    
    rect(center.x, center.y, dimx, dimy, 20);
    
    fill(cols[1], fillAlpha);
    text(title, center.x, center.y-(dimens.y/2)+30);

    rectMode(CORNER);
    menuButtons.forEach((b) -> b.render());
  }
}
