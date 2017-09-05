// color calulation thread

float alpha = 0.025;

color bgColor = color( 0 , 0 , 0 );
color outlineColor = color( 255 , 255 , 255 );
color bandColor = color( 32 );

//color bgColor = color( 255 , 255 , 255 );
//color outlineColor = color( 0 , 0 , 0 );

float[] bandStart = { 0.20 , 0.37 , 0.47 , 0.57 , 0.70 };
float[] bandEnd   = { 0.30 , 0.43 , 0.53 , 0.63 , 0.80 };
float[] bandWidth = { 0.007 , 0.007 , 0.007 , 0.007 , 0.007 };
int numBands = 5;


class ColorData {
  int num;
  // pixel information
  color[] col;
  color[] cola;
  
  ColorData( int numIn ) {
    num = numIn;
    col = new color[num];
    for( int i = 0 ; i < num ; i++ ) {
      col[i] = color(0);
    }
  }
}

class ColorDataOutput {
  int num;
  // pixel information
  color[] col;
  
  ColorDataOutput( int numIn ) {
    num = numIn;
    col = new color[num];
    for( int i = 0 ; i < num ; i++ ) {
      col[i] = color(0);
    }
  }
}

void thread_CalculateColor0() {
  flag_CalculateColor0_done = false;
  for( int i = 0 ; i < CD0.num ; i++ ) {
      float fldVal = lerp( FDO.fld0[i] , FDO.fld1[i] , currentProgress );
      float hueVal = lerp360( FDO.hue0[i] , FDO.hue1[i] , currentProgress );
      float satVal = lerp( FDO.sat0[i] , FDO.sat1[i] , currentProgress );
      float briVal = lerp( FDO.bri0[i] , FDO.bri1[i] , currentProgress );
      color c = bgColor;
      for( int b = 0 ; b < numBands ; b++ ) {
        if( fldVal >= (bandStart[b]-bandWidth[b]) && fldVal <= (bandEnd[b]+bandWidth[b]) ) {
          if( fldVal >= bandStart[b] && fldVal <= bandEnd[b] ) {
            c = hsbColor( (hueVal+b*60)%360 , satVal , briVal );
          } else {
            c = outlineColor;
          }
        }
      }
      CD0.col[i] = lerpColor( CD0.col[i] ,  c , alpha );
    }
  flag_CalculateColor0_done = true;
  return;
}

void thread_UpdateColor0() {
  flag_UpdateColor0_done = false;
  for( int i = 0 ; i < CD0.num ; i++ ) {
    CDO0.col[i] = CD0.col[i];
  }
  flag_UpdateColor0_done = true;
  //println( "flag_UpdateColor0_done " + flag_UpdateColor0_done );
  return;
}

void thread_CalculateColor1() {
  flag_CalculateColor1_done = false;
  for( int i = 0 ; i < CD1.num ; i++ ) {
    float fldVal = lerp( FDO.fld0[i+CD0.num] , FDO.fld1[i+CD0.num] , currentProgress );
    float hueVal = lerp360( FDO.hue0[i+CD0.num] , FDO.hue1[i+CD0.num] , currentProgress );
    float satVal = lerp( FDO.sat0[i+CD0.num] , FDO.sat1[i+CD0.num] , currentProgress );
    float briVal = lerp( FDO.bri0[i+CD0.num] , FDO.bri1[i+CD0.num] , currentProgress );
    color c = bgColor;
    for( int b = 0 ; b < numBands ; b++ ) {
      if( fldVal >= (bandStart[b]-bandWidth[b]) && fldVal <= (bandEnd[b]+bandWidth[b]) ) {
        if( fldVal >= bandStart[b] && fldVal <= bandEnd[b] ) {
          c = hsbColor( (hueVal+b*60)%360 , satVal , briVal );
        } else {
          c = outlineColor;
        }
      }
    }
    CD1.col[i] = lerpColor( CD1.col[i] ,  c , alpha );
  }
  flag_CalculateColor1_done = true;
  return;
}


void thread_UpdateColor1() {
  flag_UpdateColor1_done = false;
  for( int i = 0 ; i < CD1.num ; i++ ) {
    CDO1.col[i] = CD1.col[i];
  }
  flag_UpdateColor1_done = true;
  //println( "flag_UpdateColor1_done " + flag_UpdateColor1_done );
  return;
}