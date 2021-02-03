#include <SoftwareSerial.h> // for bluetooth
#include <Wire.h>  // 
#include <LiquidCrystal_I2C.h>// for LCD
#define inPin0 0

// Set the pins on the I2C chip used for LCD connections:
//                    addr, en,rw,rs,d4,d5,d6,d7,bl,blpol
LiquidCrystal_I2C lcd(0x27, 2, 1, 0, 4, 5, 6, 7, 3, POSITIVE);  // 設定 LCD I2C 位址
SoftwareSerial bluetooth(0, 1); // RX, TX

//for bluetooth
int start = 0;
int cancel = 0;

//for PD circuit
int pinRead0;
float pVolt0;
String voltage;
byte buf[5];

//time
int offset;

void setup() {
  ////////bluetooth setup/////////
  bluetooth.begin(115200);
  ///////////LCD setup////////////
  lcd.begin(16, 2);      // 初始化 LCD，一行 16 的字元，共 2 行，預設開啟背光

  // 閃爍三次
  for (int i = 0; i < 3; i++) {
    lcd.backlight(); // 開啟背光
    delay(250);
    lcd.noBacklight(); // 關閉背光
    delay(250);
  }
  lcd.backlight();

  // 輸出初始化文字
  lcd.setCursor(0, 0); // 設定游標位置在第一行行首
  lcd.print("Welcome!!");
  delay(2000);
  lcd.clear();
  lcd.print("MBL Present");
  delay(2000);
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("A.baumannii ");
  lcd.setCursor(0, 1);
  lcd.print("Detector");
  delay(2000);
  lcd.clear();
}

void loop() {
  //after start
  while (start == 1 && cancel == 0) {
    
    //get PD signal and sent
    pinRead0 = analogRead(inPin0);
    pVolt0 = pinRead0 / 1024.0 * 5.0;
    voltage =  String(pVolt0, 2);
    voltage.getBytes(buf, 5);
    bluetooth.write(buf, 4);

    lcd.setCursor(0, 0);
    lcd.print((millis() - offset) / 1000);
    lcd.print(" sec");
    lcd.setCursor(0, 1);
    lcd.print("signal ");
    lcd.print(pVolt0);
    lcd.print(" V");

    delay(100);
    //dectect cancel message
    if (bluetooth.available())
    {
      if (bluetooth.read() == 'c') //c for cancel
      {
        //bluetooth.println("Cancel");
        cancel = 1;
        start = 0;
      }
    }
  }

    if (bluetooth.available())
    {
      if (bluetooth.read() == 's') //s for start
      {
        start = 1;
        cancel = 0;
      }
    }
  
  offset = millis();
}
