// fld calc thread

float fDetail = 0.010;
float fSpeed = 0.010;
float hDetail = 0.002;
float hSpeed = 0.005;
float sDetail = 0.029;
float sSpeed = 0.05;
float bDetail = 0.049;
float bSpeed = 0.05;
float masterSpeed = 3;

class FieldDataOut {
  int num;
  
  // pixel values
  float[] fld0;
  float[] hue0;
  float[] sat0;
  float[] bri0;
  float[] fld1;
  float[] hue1;
  float[] sat1;
  float[] bri1;
  
  FieldDataOut() {
    num = PA.num;
    fld0 = new float[num];
    hue0 = new float[num];
    sat0 = new float[num];
    bri0 = new float[num];
    fld1 = new float[num];
    hue1 = new float[num];
    sat1 = new float[num];
    bri1 = new float[num];
    
    for( int i = 0 ; i < num ; i++ ) {
      fld0[i] = 0.5;
      hue0[i] = 0.5;
      sat0[i] = 0.5;
      bri0[i] = 0.5;
      fld1[i] = 0.5;
      hue1[i] = 0.5;
      sat1[i] = 0.5;
      bri1[i] = 0.5;
    }
  }
}

class FieldData {
  int num;
  
  // position information
  float[] xf;
  float[] yf;
  float[] xh;
  float[] yh;
  float[] xs;
  float[] ys;
  float[] xb;
  float[] yb;
  
  // pixel values
  float[] fld2;
  float[] hue2;
  float[] sat2;
  float[] bri2;
  
  // time information
  float tf = 0;
  float th = 0;
  float ts = 0;
  float tb = 0;
  
  FieldData() {
    num = PA.num;
    xf = new float[num];
    yf = new float[num];
    xh = new float[num];
    yh = new float[num];
    xs = new float[num];
    ys = new float[num];
    xb = new float[num];
    yb = new float[num];
    
    fld2 = new float[num];
    hue2 = new float[num];
    sat2 = new float[num];
    bri2 = new float[num];
    
    for( int i = 0 ; i < num ; i++ ) {
      xf[i] = PA.P[i].xr * fDetail;
      yf[i] = PA.P[i].yr * fDetail;
      xh[i] = (PA.P[i].xr+1*width) * hDetail;
      yh[i] = PA.P[i].yr * hDetail;
      xs[i] = (PA.P[i].xr+2*width) * sDetail;
      ys[i] = PA.P[i].yr * sDetail;
      xb[i] = (PA.P[i].xr+3*width) * bDetail;
      yb[i] = PA.P[i].yr * bDetail;
      fld2[i] = 0.5;
      hue2[i] = 0.5;
      sat2[i] = 0.5;
      bri2[i] = 0.5;
    }
  }
}

void thread_CalculateField() {
  flag_CalculateField_done = false;
  
  for( int n = 0 ; n < FD.num ; n++ ) {
    // handle request for progress
    if( fldFlag_draw_requestProgress ) {
      fldFlag_draw_requestProgress = false;
      fldProgress = float(n) / float(FD.num);
      fldFlag_thread_progressReady = true;
    }
    
    // update next element of fld2
    FD.fld2[n] = noise( FD.xf[n] , FD.yf[n] , FD.tf );
    FD.hue2[n] = (noise( FD.xh[n] , FD.yh[n] , FD.th )*1080)%360;
    FD.sat2[n] = noise( FD.xs[n] , FD.ys[n] , FD.ts )*1;
    FD.bri2[n] = (noise( FD.xb[n] , FD.yb[n] , FD.tb )+ 0.25 );
    if( FD.bri2[n] > 1 ) { FD.bri2[n] = 1; }
  }
  FD.tf += fSpeed*masterSpeed;
  FD.th += hSpeed*masterSpeed;
  FD.tb += bSpeed*masterSpeed;
  FD.ts += sSpeed*masterSpeed;
  
  flag_CalculateField_done = true;
  return;
}

void thread_UpdateField() {
  flag_UpdateField_done = false;
  
  for( int i = 0 ; i < FD.num ; i++ ) {
    FDO.fld0[i] = FDO.fld1[i];
    FDO.fld1[i] = FD.fld2[i];
    FDO.hue0[i] = FDO.hue1[i];
    FDO.hue1[i] = FD.hue2[i];
    FDO.sat0[i] = FDO.sat1[i];
    FDO.sat1[i] = FD.sat2[i];
    FDO.bri0[i] = FDO.bri1[i];
    FDO.bri1[i] = FD.bri2[i];
  }
  flag_UpdateField_done = true;
  //println( "flag_UpdateField_done " + flag_UpdateField_done );
  return;
}