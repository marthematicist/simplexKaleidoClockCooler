String zip = "98264";
String APIkey = "41ece43d5325fc28";
Boolean liveData = false;    // set true to get real data from api, false for testing
Boolean logClockUpdateTime = false;

volatile PixelArray PA;

// fld: controls the field ( background, outline, or fill )
volatile float fldProgress = 0;
volatile float currentProgress = 0;

volatile boolean flag_CalculateField_done = true;
volatile boolean flag_UpdateField_done = true;

volatile boolean flag_CalculateColor0_done = true;
volatile boolean flag_UpdateColor0_done = true;
volatile boolean flag_CalculateColor1_done = true;
volatile boolean flag_UpdateColor1_done = true;


volatile boolean fldFlag_thread_readyToUpdate = false;
volatile boolean fldFlag_draw_goUpdate = false;
volatile boolean fldFlag_thread_doneUpdating = false;
volatile boolean fldFlag_draw_requestProgress = false;
volatile boolean fldFlag_thread_progressReady = false;

int num0;
int num1;
volatile boolean colFlg_draw_goRender0 = false;
volatile boolean colFlg_draw_goRender1 = false;
volatile boolean colFlg_thread_Rendering0 = false;
volatile boolean colFlg_thread_Rendering1 = false;
volatile boolean colFlg_thread_doneRendering0 = false;
volatile boolean colFlg_thread_doneRendering1 = false;
volatile boolean colFlg_draw_goUpdate0 = false;
volatile boolean colFlg_draw_goUpdate1 = false;
volatile boolean colFlag_thread_Updating0 = false;
volatile boolean colFlag_thread_Updating1 = false;
volatile boolean colFlag_thread_doneUpdating0 = false;
volatile boolean colFlag_thread_doneUpdating1 = false;
volatile boolean colFlag_thread_loopComplete0 = false;
volatile boolean colFlag_thread_loopComplete1 = false;


// resolution helpers
int halfWidth;
int halfHeight;

PGraphics pg;

// clock constants
float outerRadius;
float innerRadius;



float borderWidth;
int millisOffset; 

Clock clock;

volatile FieldData FD; 
volatile FieldDataOut FDO; 
volatile ColorData CD0;
volatile ColorData CD1;
volatile ColorData CDO0;
volatile ColorData CDO1;

void setup() {
  //frameRate(25);
  size( 800 , 480 );
  pg = createGraphics( width , height );
  halfWidth = width/2;
  halfHeight = height/2;
  background(bgColor);

  
  clock = new Clock();

  outerRadius = 0.65*width;
  innerRadius = -1;
  
  PA = new PixelArray();
  num0 = PA.num/2;
  num1 = PA.num-num0;
  FD = new FieldData();
  FDO = new FieldDataOut();
  CD0 = new ColorData( num0 );
  CDO0 = new ColorData( num0 );
  CD1 = new ColorData( num1 );
  CDO1 = new ColorData( num1 );
  
  
  
}

boolean logOut = false;
void draw() {
  int frameStartTime = millis();
  //background(bgColor);
  
  // check status of field calculations and set a flag
  boolean fieldCalcsDone = flag_CalculateField_done;
  
  // UPDATE STEP
  // update color data
  thread( "thread_UpdateColor0" );
  thread( "thread_UpdateColor1" );
  // check if Field Data is ready to update. if so, update it.
  if( fieldCalcsDone ) {
    thread( "thread_UpdateField" );
    println( "NEW FIELD DATA STARTED AT FRAME: " + frameCount );
    // current progress is now zero
    currentProgress = 0;
  } else {
    // if Field Data not ready, get current progress
    currentProgress = float(calcFieldCounter)/float(calcFieldCountTo);
  }
  // wait until all updating is complete
  while( !( flag_UpdateField_done && flag_UpdateColor0_done && flag_UpdateColor1_done ) ) {
    //println( "waiting for update to complete: " + flag_UpdateField_done + "," + flag_UpdateColor0_done + "," + flag_UpdateColor1_done );
  }
  
  println( "Update done at: " + (millis() - frameStartTime) );
    
  
  
    
  // CALCULATE, DRAW, and log STEP
  // check if field calculations are ready to restart. If so, restart.
  if( fieldCalcsDone ) {
    thread( "thread_CalculateField" );
  }
  // start color calculations
  thread( "thread_CalculateColor0" );
  thread( "thread_CalculateColor1" );
  // draw the pixels
  loadPixels();
  for( int i = 0 ; i < width*height ; i++ ) {
    int ind = PA.I[i];
    if( ind >=0 ) {
      if( ind < num0 ) {
        pixels[ i ] = CDO0.col[ ind ];
      } else {
        pixels[ i ] = CDO1.col[ ind-num0 ];
      }
    }
  }
  updatePixels();
  println( "Pixels done at: " + (millis() - frameStartTime) );
  // WAIT STEP
  // wait until color calculations are complete before ending the frame
  while( !( flag_CalculateColor0_done && flag_CalculateColor1_done ) ) {
    //println( "Waiting for color calcs: " + flag_CalculateColor0_done + "," + flag_CalculateColor1_done );
  }
  println( "Color calcs done at: " + (millis() - frameStartTime) );
  
  // Take care of output and housekeeping
  // framerate logger
  if( frameCount%500 == 0 ) {
    println( "frameRate: " , frameRate );
  }
  // time keepers
  if( second() != prevSecond ) {
    prevSecond = second();
    secondChanged = true;
  }
  if( minute() != prevMin ) {
    prevMin = minute();
    minuteChanged = true;
  }
  if( hour() != prevHour ) {
    prevHour = hour();
    hourChanged = true;
    clock.updateWeather();
  }
  if( day() != prevDay ) {
    prevDay = day();
    dayChanged = true;
    clock.updateAstronomy();
  }
  // clock drawers
  clock.drawClock();
  // input doers
  if( mouseDownQuit ) {
    if( millis() - mousePressTime > mousePressTimeout ) {
      exit();
    }
    if( millis() - mousePressTime > mouseMessageDelay ) {
      String msg = "CLOSING IN " + ( (mousePressTimeout - (millis() - mousePressTime) )/1000+1 );
      showSystemMessage( msg );
    }
  }
  if( alphaSliderEngaged ) {
    alpha = lerpCube( alphaMin , alphaMax , float(mouseX)/float(width) );
    String msg = "smoothness =  " + nf( float( round( alpha*1000 ) ) / 1000 , 0 , 3);
    showSystemMessage( msg );
  }
  if( speedSliderEngaged ) {
    masterSpeed = lerpSquare( speedMin , speedMax , float(mouseX)/float(width) );
    String msg = "speed =  " + nf( float( round( masterSpeed*100 ) ) / 100 , 0 , 2);
    showSystemMessage( msg );
  }
  // screenshot makers
  if( captureScreenshot ) {
    captureScreenshot = false;
    save( "screenShot.jpg" );
  }
  
  
  
  //exit();
  
  println( "Frame done at: " + (millis() - frameStartTime) );
  println("_______________");
}

int prevSecond = -1;
int prevMin = -1;
int prevHour = -1;
int prevDay = -1;
boolean secondChanged = false;
boolean minuteChanged = false;
boolean hourChanged = false;
boolean dayChanged = false;
boolean resetClock = false;

boolean mouseDownQuit = false;
int mousePressTime = 0;
int mousePressTimeout = 6000;
int mouseMessageDelay = 1000;

float sliderHeight = 30;
boolean speedSliderEngaged = false;
boolean alphaSliderEngaged = false;
float alphaMin = 0.001;
float alphaMax = 1;
float speedMin = 0;
float speedMax = 10;

boolean captureScreenshot = false;

void mousePressed() {
  if( mouseY >= sliderHeight && height - mouseY >= sliderHeight ) { 
    mouseDownQuit = true;
    if( mouseX >= halfWidth ) { clock.nextClock(); }
    else { clock.prevClock(); }
  } else {
    if( mouseY >sliderHeight ) {
      speedSliderEngaged = true;
    }
    if( height - mouseY > sliderHeight ) {
      alphaSliderEngaged = true;
    }
  }
  
  resetClock = true;
  mousePressTime = millis();
}

void mouseReleased() {
  mouseDownQuit = false;
  speedSliderEngaged = false;
  alphaSliderEngaged = false;
  
}

void keyPressed() {
  if( key == 's' ) {
    captureScreenshot = true;
  }
}

void showSystemMessage( String systemText ) {
  textAlign(CENTER,CENTER);
      textSize(40);
      rectMode(CENTER);
      fill(255,0,0,196);
      stroke( 255 );
      strokeWeight( 5);
      float msgWidth = textWidth( systemText );
      rect(halfWidth , halfHeight+5 , msgWidth + 20 , 60 , 10 , 10 , 10 , 10 );
      fill(255);
      text( systemText , halfWidth , halfHeight );
}


float lerpSquare( float val1 , float val2 , float amt ) {
  return lerp( val1 , val2 , amt*amt );
}

float lerpCube( float val1 , float val2 , float amt ) {
  return lerp( val1 , val2 , amt*amt*amt );
}