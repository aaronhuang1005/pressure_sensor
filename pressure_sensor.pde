import processing.serial.*;

Serial myPort;
PrintWriter outputl;

int A4 = 0;
int A5 = 0;
int A6 = 0;
int A7 = 0;
int time = 740;
int shift = 2;
int right = 0;
int right_pre = 0;
int down = 0;
int down_pre = 0;
int up = 0;
int up_pre = 0;
int left = 0;
int left_pre = 0;
Boolean status = true;
int check = 0;
Boolean palse = false;
int sit_time=0;
int port = 0;


void setup(){
  size(1280, 640);
  windowResize(1280, 640);
  frameRate(30);
  background(0x20);
  
  outputl = createWriter("positions.txt");
  
  A4 = 0;
  A5 = 0;
  A6 = 0;
  A7 = 0;
  time = 740;
  shift = 1;
  right = 0;
  right_pre = 0;
  down = 0;
  down_pre = 0;
  up = 0;
  up_pre = 0;
  left = 0;
  left_pre = 0;
  status = true;
  check = 0;
  sit_time = 0;
  
  try {
    println(Serial.list()[0]);
    myPort = new Serial(this, Serial.list()[port], 9600);
    myPort.write("/data 1");
  }catch(RuntimeException e) {
    background(100,0,0);
    fill(255, 255, 255);
    textSize(80);
    text("ERROR", 540, 320);
    println("Error setup");
    port+=1;
    status = false;
  }
  
}

void draw () {
  if (status == true){
    //String out = "A4 "+Integer.toString(A4)+"A5 "+Integer.toString(A5)+"A6 "+Integer.toString(A6)+"A7 "+Integer.toString(A7);
    //println(out);
    if ( A4>1023 || A5>1023 || A6>1023 || A7>1023 ){
      fill(0x20);
      rect(0, 0, 640, 640);
    }
    
    noStroke();
    fill(0x30);
    rect(10, 10, 640, 615, 10);
    
    //A4
    fill(204, 102, 0);
    circle(160,160,A4/3.5);
    
    fill(255, 255, 255);
    textSize(30);
    text("A4", 145, 165);
    textSize(20);
    text(Integer.toString(A4), 145, 185);
    
    //A5
    fill(204, 102, 0);
    circle(480,160,A5/3.5);
    
    fill(255, 255, 255);
    textSize(30);
    text("A5", 465, 165);
    textSize(20);
    text(Integer.toString(A5), 465, 185);
    
    //A6
    fill(204, 102, 0);
    circle(160,475,A6/3.5);
    
    fill(255, 255, 255);
    textSize(30);
    text("A6", 145, 485);
    textSize(20);
    text(Integer.toString(A6), 145, 505);
    
    //A7
    fill(204, 102, 0);
    circle(480,475,A7/3.5);
    
    fill(255, 255, 255);
    textSize(30);
    text("A7", 465, 485);
    textSize(20);
    text(Integer.toString(A7), 465, 505);
    
    
    
    if((A4+A5+A6+A7)/4 >= 512 && palse == false){
      palse = true;
      sit_time = millis();
    }else if((A4+A5+A6+A7)/4 < 512 ){
      palse = false;
    }
    
    
    if (check == 0){
      
      fill(255, 255, 255);
      textSize(20);
      text("A4 - A5", 670, 115);
      stroke(100, 100, 100);
      line(740,110,1240,110);
      
      up = (A4 - A5)/17;
      stroke(0, 255, 0);
      line(time-shift,110-up_pre,time,110-up);
      up_pre = up;
  
      fill(255, 255, 255);
      textSize(20);
      text("A6 - A7", 670, 245);
      stroke(100, 100, 100);
      line(740,240,1240,240);
      
      down = (A6 - A7)/17;
      stroke(0, 255, 0);
      line(time-shift,240-down_pre,time,240-down);
      down_pre = down;
      
      fill(255, 255, 255);
      textSize(20);
      text("A5 - A7", 670, 425);
      stroke(100, 100, 100);
      line(740,420,1240,420);
      
      right = (A5 - A7)/17;
      stroke(0, 255, 0);
      line(time-shift,420-right_pre,time,420-right);
      right_pre = right;
      
      fill(255, 255, 255);
      textSize(20);
      text("A4 - A6", 670, 565);
      stroke(100, 100, 100);
      line(740,560,1240,560);
      
      left = (A4- A6)/17;
      stroke(0, 255, 0);
      line(time-shift,560-left_pre,time,560-left);
      left_pre = left;
      
      noStroke();
      fill(0x20);
      quad(time-shift+1, 0,time-shift+30,0, time-shift+30,640,time-shift+1, 640);
      
      time  = time + shift;
      
      if (time + shift >=1240){
        time = 740;
        //println("fresh");
        noStroke();
        fill(0x20);
        quad(700, 0,742,0,742,640,700,640);
      }
    }else if(check == 1){
      noStroke();
      fill(0x20);
      rect(650, 0, 1280, 640, 0);
      time = 740;
      
      stroke(0x30);
      line(770,330,1230,330);
      line(1000,100,1000,560);
      
      noStroke();
      fill(150, 30, 10);
      circle(1000,330,90);
      
      float c_x,c_y,x,y,c;
      c = A4 + A5 + A6 + A7;
      c_x = 800*A4 + 1200*A5 + 800* A6 + 1200*A7;
      c_y = 130*A4 + 130*A5 + 530* A6 + 530*A7;
      
      if (c == 0.0){
        x = 1000.0;
        y = 330.0;
      }else{
        x = c_x / c;
        y = c_y / c;
      }

      fill(250, 150, 100);
      circle(x,y,30);
      
    }else if(check == 2){
      noStroke();
      fill(0x20);
      rect(650, 0, 1280, 640, 0);
      String put;
      int R,G,B;
      if(palse == true){
        int time = millis() - sit_time;
        //println(time);
        put = Integer.toString(time/3600000) + " : " + Integer.toString((time%3600000)/60000) + " : " + Integer.toString(((time%3600000)%60000)/1000);
        if(time<1800000){
          R = 255;
          G = 255;
          B = 255;
        }else{
          R = 255;
          G = 0;
          B = 0;
        }
      }else{
        put = "0 : 0 : 0";
        R = 0;
        G = 255;
        B = 0;
        
      }
      fill(R, G, B);
      textSize(50);
      text(put, 920, 320);
      
    }
    outputl.println(Integer.toString(hour())+":"+Integer.toString(minute())+":"+Integer.toString(second())+"  "+A4 + "  " + A5 + "  " + A6 + "  " + A7 );
  }
}


void serialEvent (Serial myPort) 
{
  if(status == true){
    try{
      String inString = myPort.readStringUntil('\n');
      if (inString != null) 
      {
        
        inString = trim(inString);
        String[] tokens = inString.split("/");
        
        if (tokens.length!=4) 
        { 
          
          println("Error length input");
          
        }else{
          
          A4 = Integer.parseInt(tokens[0]);
          A5 = Integer.parseInt(tokens[1]);
          A6 = Integer.parseInt(tokens[2]);
          A7 = Integer.parseInt(tokens[3]);
          
        }
      }
    }catch(RuntimeException e) {
      background(100,0,0);
      fill(255, 255, 255);
      textSize(80);
      text("ERROR", 540, 320);
      println("Error Null input");
      myPort.write("/data 1");
      
      status = false;
      setup();
    }
  }
}

void keyPressed(){
  if(key == ' ') {
    check++;
    check = check % 3;
    noStroke();
    fill(0x20);
    rect(650, 0, 1280, 640, 0);
    time = 740;
    
  }else if(key == CODED) {
    if(keyCode == LEFT){
    }
    else if(keyCode == RIGHT){
      myPort.write("/blink");
    }
    else if(keyCode == UP){
      myPort.write("/blink_slow");
    }else if(keyCode == DOWN){
      myPort.write("/blink_fast");
    }
  }else if(key == ESC){
    outputl.flush(); // Writes the remaining data to the file
    outputl.close();
    myPort.write("/data 0");
    exit();
  }
}
