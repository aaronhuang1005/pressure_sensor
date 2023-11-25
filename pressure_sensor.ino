#define remider 11
#define up 9
#define left 6
#define right 5
#define down 3
#define analogIn1 A4
#define analogIn2 A5
#define analogIn3 A6
#define analogIn4 A7
#define settime1 1800000
#define settime2 2400000

int valx;
int valy;
float a1,a2,a3,a4;
bool blink,status,check;
unsigned long sit_status;
unsigned long time,sit_time;
unsigned long outputtime;
unsigned long pre_time;
unsigned long blink_time;


void setup() {
  pinMode(remider, OUTPUT);
  pinMode(up, OUTPUT);
  pinMode(left, OUTPUT);
  pinMode(right, OUTPUT);
  pinMode(down, OUTPUT);
  
  valx = 0;
  valy = 0;
  blink = false;
  //status = false;
  status = true;
  check = false;
  time = 0;
  pre_time = 0; 
  outputtime = 65;
  blink_time = 10000;
  sit_status = 0;
  sit_time = 0;
  
  
  Serial.begin(9600);
}

void loop() {
  
  a1 = analogRead(analogIn1);
  a2 = analogRead(analogIn2);
  a3 = analogRead(analogIn3);
  a4 = analogRead(analogIn4);

  if( a1 + a2 + a3 + a4 == 0){
    valx = 0;
    valy  = 0;
  }else{
    valx = (-255.0*a1+255.0*a2-255.0*a3+255.0*a4)/(a1 + a2 + a3 + a4);
    valy = (255.0*a1+255.0*a2-255.0*a3-255.0*a4)/(a1 + a2 + a3 + a4);
    
  }
  //Serial.println(String(valx)+","+String(valy));
  
  if(valx>0){
    analogWrite(right, valx);
    analogWrite(left, 0);
  }else if(valx<0){
    analogWrite(right, 0);
    analogWrite(left, valx*-1);
  }else{
    analogWrite(right, 0);
    analogWrite(left, 0);
  }

  if(valy>0){
    analogWrite(up, valy);
    analogWrite(down, 0);
  }else if(valy<0){
    analogWrite(up, 0);
    analogWrite(down, valy*-1);
  }else{
    analogWrite(up, 0);
    analogWrite(down, 0);
  }

  if(status){
    if ( millis() - time >= outputtime){
      //String out = "A4:" + String(analogRead(analogIn1)) + "  A5:" + String(analogRead(analogIn2)) + "  A6:"+ String(analogRead(analogIn3)) + "  A5:" + String(analogRead(analogIn4));
      String out = String(analogRead(analogIn1)) + "/" + String(analogRead(analogIn2)) + "/"+ String(analogRead(analogIn3)) + "/" + String(analogRead(analogIn4));
      Serial.println(out);
      time = millis();
    }
  }

  //------------------------------------------------------------------------------------------------------


  if((a1+a2+a3+a4)/4 >= 512 && check == false){
    check = true;
    sit_time = millis();
    //Serial.println("ON");
  }else if((a1+a2+a3+a4)/4 < 512 ){
    check = false;
    //Serial.println("Off");
  }

  if(millis() - sit_time > settime2 && (a1+a2+a3+a4)/4 >= 512){
    sit_status = 2;
    //Serial.println("2");
  }else if(millis() - sit_time > settime1 && (a1+a2+a3+a4)/4 >= 512){
    sit_status = 1;
    //Serial.println("1");
  }else{
    sit_status = 0;
    blink = false;
  }

  if(sit_status == 1){
    blink_time = 100;
  }

  if(sit_status == 2){
    blink_time = 50;
  }
  
  if(millis()- pre_time >= blink_time && sit_status > 0){
    blink = ! blink;
    pre_time = millis();
  }
  
  digitalWrite(remider , blink);

  //------------------------------------------------------------------------------------------------------

  if(Serial.available()){
    String s = Serial.readString();
    String temp;

    if(s == "/blink_slow"){
      sit_status = 1;
    }

    if(s == "/blink_fast"){
      sit_status = 2;
    }
    if(s == "/blink_off"){
      sit_status = 0;
    }

    for(int i=0 ; i<7 ; i++){
      temp+=s[i];
    }
    if(temp == "/data 1"){ //show data
      status = true;
      
      if(s.length()>8){ // change the output time
        String num;
        for(int i=8; i< s.length()-1;i++){
          if( s[i] > 47 and s[i] < 58){
            num+=s[i];
          }
        }
        outputtime = num.toInt();
      }
      
    }else if(temp == "/data 0"){ //don't show data
      status = false;
    }else if(temp =="/data\n"){
      temp = "Output: " + String(status) + "   Output time: " + String(outputtime) + "ms";
      Serial.println(temp);
    }else{
      //Serial.println("Wrong code...");
    }
  }
}
