# Pressure Sensor 坐姿感測

作者：Aaron Huang

本文將介紹關於坐墊坐姿感測，內部的佈線、整體機構、成品、介面UI的介紹，原始碼的Review，除了幫助了解專題的內容，往後若有相關的專案也有相對應的參考。

>github連結：[aaronhuang1005/pressure_sensor](https://github.com/aaronhuang1005/pressure_sensor)\
>目錄：
>[TOC]

## 機構與佈線設計

受限於時間與經費，此次是以簡易的微處理機 Arduino Nano 作為主要的資料處裡核心，資料傳輸是序列埠傳輸(有線傳輸)，由四個壓力感測器利用電阻分壓的方式將壓力的阻值變化轉化成電壓變化，使微處理機能以類比方式讀取，而在微處理機上有簡易的久坐提醒以及偏移指示，將資料傳輸到電腦後，由電腦的介面讀取並轉換成不同的資訊。\
\
由上述轉換為設計機構後可以視為3個部分：**壓力感測器**、**主板**以及**電腦**

1. **壓力感測器**\
元件為四個壓力感測器、分壓的電阻以及與主板傳輸接口，由於會因受力而產生影響，因此此機構設計希望能承受使用者的重量以及運作不受使用者的移動影響，需要較為堅固
2. **主板**\
傳輸接口、微處理機、久坐提示燈以及偏移指示燈，由於此機構會提供給使用者資訊以及資料的傳輸，需要有一定的美觀要求以及穩定性的要求。
3. **電腦**\
顯示資訊用，後面將有篇幅介紹

佈線部分由於上述機構的電路設計都並不複雜，因此要求佈線展用空間越少越好，以下是佈線圖，由DIY layout繪製，左邊為主板，右邊為壓力感測(省略壓力感測器僅留分壓以及傳輸接口)：\
\
![AnyConv.com__下載 (1)](https://hackmd.io/_uploads/r1xqJyC4p.jpg)
\
\
傳輸先接口分別對到 Arduino Nano 的類比腳位 A4 A5 A6 A7，久坐指示燈(紅)對應到數位腳位 9，\
四個偏移指示燈(藍)則是對應到數位腳位 6 5 3 (以上數位接腳皆支援PWM)\
以下是機構的實作成品圖：\
\
![AnyConv.com__下載](https://hackmd.io/_uploads/HkQsJyA46.jpg)

## 介面UI

介面顯示是分為簡易顯示以及電腦端呈現，簡易顯示由五顆LED顯示(一紅四藍)。\
左上紅燈為久坐指示燈，根據設定的時間分別會無閃爍、慢閃爍(30min)、快閃爍(40min)；其他的藍燈則是坐姿偏移的指示燈，根據使用者坐姿的歪斜程度顯示前、後、左、右。

:::info
以下是主板上LED的顯示，共五個LED分為兩個部分:

![未命名](https://hackmd.io/_uploads/HyCw8zJHp.png)

:::

\
而電腦端的顯示較為進階，能顯示目前壓力分布的情形、重心偏移的位置、左右及前後的偏移差異以及久坐的時間，而操作是由鍵盤操作，由空白鍵切換上述顯示資訊(偏移差->重心偏移圖->久坐時間)，而ESC則是退出。

:::info
以下是介面UI的幾個的頁面(3/3):

1. 左側為壓力分佈，右側為壓力差值(1/3)

![image](https://hackmd.io/_uploads/ByrT8zRVT.png)

\
2. 按下空白鍵後，右側切換為重心分佈(2/3)

![image](https://hackmd.io/_uploads/Syfxuf0Ep.png)

\
3. 再次按下空白鍵後，右側切換為久坐時間(3/3)

![image](https://hackmd.io/_uploads/rkc2_fA4T.png)

:::

## Code Review 原始碼註解

以下會分別介紹 Arduino Nano 以及 Processing 的程式原始碼。

### Arduino Nano：

```c=
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
  
  //------------------------Read analog value
  
  a1 = analogRead(analogIn1);
  a2 = analogRead(analogIn2);
  a3 = analogRead(analogIn3);
  a4 = analogRead(analogIn4);

  if( a1 + a2 + a3 + a4 == 0){ //caculate the value of the LED
    valx = 0;
    valy  = 0;
  }else{
    valx = (-255.0*a1+255.0*a2-255.0*a3+255.0*a4)/(a1 + a2 + a3 + a4);
    valy = (255.0*a1+255.0*a2-255.0*a3-255.0*a4)/(a1 + a2 + a3 + a4);
  }
  
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

  if(status){  //set ouput imformation
    if ( millis() - time >= outputtime){
      String out = String(analogRead(analogIn1)) + "/" + String(analogRead(analogIn2)) + "/"+ String(analogRead(analogIn3)) + "/" + String(analogRead(analogIn4));
      Serial.println(out);
      time = millis();
    }
  }

  //------------------------set timer

  if((a1+a2+a3+a4)/4 >= 512 && check == false){
    check = true;
    sit_time = millis();
  }else if((a1+a2+a3+a4)/4 < 512 ){
    check = false;
  }
    
  //------------------------sit time judge and blink

  if(millis() - sit_time > settime2 && (a1+a2+a3+a4)/4 >= 512){
    sit_status = 2;
  }else if(millis() - sit_time > settime1 && (a1+a2+a3+a4)/4 >= 512){
    sit_status = 1;
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

  //------------------------outer control

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
```

由於原始碼有些長，會以註解部分分開說明：

#### **宣告變數以及定義常數**

```c=
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
```

這邊的程式碼大部分是在定義下方計算的結果、檢查值以及讀入的數值，而定義的常數是和腳位設定以及久坐時間設定相關

#### **設定腳位與初值設定**

```c=
void setup() {
  pinMode(remider, OUTPUT);
  pinMode(up, OUTPUT);
  pinMode(left, OUTPUT);
  pinMode(right, OUTPUT);
  pinMode(down, OUTPUT);
  
  valx = 0;
  valy = 0;
  blink = false;
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
```

這裡是在做輸出腳位(LED)的設定，以及變數的初始化設定，以及USB傳輸鮑率(baud rate)的設定(9600)

#### **類比腳位計算與輸出**

```c=
  //------------------------Read analog value

  a1 = analogRead(analogIn1);
  a2 = analogRead(analogIn2);
  a3 = analogRead(analogIn3);
  a4 = analogRead(analogIn4);

  if( a1 + a2 + a3 + a4 == 0){ //calculate the value of the LED
    valx = 0;
    valy  = 0;
  }else{
    valx = (-255.0*a1+255.0*a2-255.0*a3+255.0*a4)/(a1 + a2 + a3 + a4);
    valy = (255.0*a1+255.0*a2-255.0*a3-255.0*a4)/(a1 + a2 + a3 + a4);
  }
  
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

  if(status){  //set ouput imformation
    if ( millis() - time >= outputtime){
      String out = String(analogRead(analogIn1)) + "/" + String(analogRead(analogIn2)) + "/"+ String(analogRead(analogIn3)) + "/" + String(analogRead(analogIn4));
      Serial.println(out);
      time = millis();
    }
  }
```

首先將分壓由 `analogRead()` 讀入，接下來就是以各四個點的分壓值計算每個LED所需要輸出的亮度，這裡的計算是由加權平均去計算：\
$$\frac{\sum_{i=1}^{n}{V_n X_n}}{\sum_{i=1}^{n}{V_n}}$$\
這裡可看作類似質心的計算，不過比例的分配是以四個點的分壓。\
由此計算$x$軸方向的比例以及$y$軸方向的比例，而坐標軸的分配如下圖：

![未命名1](https://hackmd.io/_uploads/r1Ya5X1BT.png)

分壓的讀入值分別對應到四邊形的四個頂點，計算出重心的$x$、$y$座標，再依據正負值分配給相應LED值\
Example：計算後重心位置為(60,-50)，$x$軸方向為正，分配亮度值給右邊的LED，而$y$軸為負，分配亮度值給下面的LED。\
\
而這部分的後面即是整合四個壓力感測器的分壓成字串，以固定的時間輸出到序列埠。

#### **計時器的設定**

```c=
  //------------------------set timer

  if((a1+a2+a3+a4)/4 >= 512 && check == false){
    check = true;
    sit_time = millis();
  }else if((a1+a2+a3+a4)/4 < 512 ){
    check = false;
  }
```

下一個部分即是久坐的時間感測，但由於需要偵測坐下的狀態以及開始計時的時間，因此需要由一個是計時器的設計，不過這個部分因判斷計時開始的條件。\
由`sit_time`這個變數儲存計時開始的時間，在坐下的條件開始符合後(四個分壓值平均大於512)，將`check`設為`true`(即持續做著)並將當下時間放入`sit_time`，當使用者離開(四個分壓值平均小於512)，將`check`設為`false`。而需要查看久坐時間便只需要判斷`check`是否為`true`，若是即將現在時間與開始時間相減即可得到久坐時間。

#### **久坐判斷以及提示**

```c=
if(millis() - sit_time > settime2 && (a1+a2+a3+a4)/4 >= 512){
    sit_status = 2;
  }else if(millis() - sit_time > settime1 && (a1+a2+a3+a4)/4 >= 512){
    sit_status = 1;
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
```

這部分即是久坐的判斷與燈號的提示，上述方法可以得到久坐的時間，那與設定的時間相比便可以知道是否為久坐，而輸出的部分則是以LED的閃爍頻率提示使用者，這裡也是以明、暗間隔時間做調整，大於或等於間隔時間即會切換LED狀態(變數`blink`)。

#### 外部控制

```c=
  //------------------------outer control

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
```

這部分僅在 trouble shooting 以及 testing 的時候做輸出以及控制使用，在主要執行流程沒有影響。
讀入序列埠傳輸進來的值做字串的分割處裡，在由此條件決定要改變控制項。

### Processing

```java=
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
```
由於圖形介面大多都是畫圖的函式，因此這部分會以各個功能函式說明：

#### **setup()**

```java=
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
```

這部分跟 Arduino 的 `setup()`有些類似，皆是僅會跑一次用來設定初值跟相關功能，這邊除了設定初使值，還有決定視窗的大小、顏色、輸入的序列埠及鮑率、輸出檔案的位置，這邊在時做的時候發現容易在設定序列埠出現error，因此藉由`try`跟`catch`去避免程式的crush。

#### **serialEvent(Serial myPort)**

```java=
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
```

這邊即是序列埠收到訊息以後，會觸發的事件函式，而由 Arduino Nano 傳輸的訊息是由`\`分開的四個分壓值的字串，因此在接收的時候利用此條件將字串分離並且放入對應的變數中，以便後續的運算。
這邊一樣有時候會出現輸入字串長度不足，或是其它因為程式啟動時間而造成數值丟失的error，因此也有做例外狀況的處裡。

#### **keyPressed()**

```java=
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
```

這個部分是當電腦的鍵盤按鍵按下以後會觸發的事件函式，而其中變數`key`則是按下按鍵的種類。真正有功能的按鍵僅有空白鍵跟ESC有功能，其他僅是測試用。空白鍵會將`check`值改變(數值範圍0~2，對應到三個頁面)，進而達到切換頁面的功能；ESC鍵則是將讀入的值寫入檔案、關閉檔案並且呼叫`exit()`函式退出程式。

#### **draw()**

這邊的`draw()`相當於 Arduino 的 `loop()`函式，皆是開始便會無限執行的主程式區，總共分成三個頁面的程式碼，在分部分說明：

##### 壓力分布顯示

```java=
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
```

這個部分主要是在顯示四個點的分壓(各點的壓力值)，圖形是以圓圈的大小去顯示數值的大小，而繪製的圖形除了圓形還有圖形上的字，方便使用者閱讀(`circle()`即是畫圓，而`text則是寫字`)

##### 計時器

```java=
if((A4+A5+A6+A7)/4 >= 512 && palse == false){
    palse = true;
    sit_time = millis();
}else if((A4+A5+A6+A7)/4 < 512 ){
    palse = false;
}
```

這個部分與 Arduino Nano 中的計時器是極度類似的程式碼，一樣是在判斷久坐開始的時間，這邊不贅述。

##### 壓力差值頁面

```java=
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
}
```

這個部分是以連續波型顯示的變化，將差值的計算結果與前一次計算的結果以線相連接(`line()`)，並且繪畫方形(`quad()`)以蓋住之前的圖形用以表示更新，整個圖形就會像是示波器一般不斷顯示波型變化。

##### 重心偏移顯示頁面

```java=
else if(check == 1){
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
  c_x = 800*A4 + 1200*A5 + 800* A6 + 1200*A7; //calculate x
  c_y = 130*A4 + 130*A5 + 530* A6 + 530*A7; //calculate y

  if (c == 0.0){
    x = 1000.0;
    y = 330.0;
  }else{
    x = c_x / c;
    y = c_y / c;
  }

  fill(250, 150, 100);
  circle(x,y,30);
}
```

這個部分也是計算加權平均，與 Arduino 上計算LED亮度大同小異，不過結果是以座標上的點顯示。

##### 久坐時間顯示頁面

```java=
else if(check == 2){
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
```

這部分是根據計時器的數值與現在的時間相減得出的運算值進行換算，由於運算結果(`time`)毫秒(ms)，因此需要換成秒(s)、分(min)、時(h)顯示，時(h)的計算為：`time`除以3600000，分(min)計算為：時計算的餘數(`time`%3600000)除以60000，秒(s)計算為：上述運算結果的餘數(((`time`%3600000)%60000))除以1000，再將運算結果顯示。

##### 寫入檔案

```java=
outputl.println(Integer.toString(hour())+":"+Integer.toString(minute())+":"+Integer.toString(second())+"  "+A4 + "  " + A5 + "  " + A6 + "  " + A7 );
```
這一行是為了將電腦讀入的數值(四個分壓值)寫入至檔案的物件`output1`，使用者按下ESC鍵結束程式才會將所有數值一併寫入檔案。

