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


void thread_CalculateColor0() {
  flag_CalculateColor0_done = false;
  for( int i = 0 ; i < num0 ; i++ ) {
      float fldVal = lerp( fld0[i] , fld1[i] , currentProgress );
      float hueVal = lerp360( hue0[i] , hue1[i] , currentProgress );
      float satVal = lerp( sat0[i] , sat1[i] , currentProgress );
      float briVal = lerp( bri0[i] , bri1[i] , currentProgress );
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
      col0a[i] = lerpColor( col0[i] ,  c , alpha );
    }
  flag_CalculateColor0_done = true;
  return;
}

void thread_UpdateColor0() {
  flag_UpdateColor0_done = false;
  for( int i = 0 ; i < num0 ; i++ ) {
    col0[i] = col0a[i];
  }
  flag_UpdateColor0_done = true;
  //println( "flag_UpdateColor0_done " + flag_UpdateColor0_done );
  return;
}

void thread_CalculateColor1() {
  flag_CalculateColor1_done = false;
  for( int i = 0 ; i < num1 ; i++ ) {
    float fldVal = lerp( fld0[i+num0] , fld1[i+num0] , currentProgress );
    float hueVal = lerp360( hue0[i+num0] , hue1[i+num0] , currentProgress );
    float satVal = lerp( sat0[i+num0] , sat1[i+num0] , currentProgress );
    float briVal = lerp( bri0[i+num0] , bri1[i+num0] , currentProgress );
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
    col1a[i] = lerpColor( col1[i] ,  c , alpha );
  }
  flag_CalculateColor1_done = true;
  return;
}


void thread_UpdateColor1() {
  flag_UpdateColor1_done = false;
  for( int i = 0 ; i < num1 ; i++ ) {
    col1[i] = col1a[i];
  }
  flag_UpdateColor1_done = true;
  //println( "flag_UpdateColor1_done " + flag_UpdateColor1_done );
  return;
}