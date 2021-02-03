#include <Wire.h>  // Arduino IDE 內建
#include <LiquidCrystal_I2C.h>
#define inPin0 0

// Set the pins on the I2C chip used for LCD connections:
//                    addr, en,rw,rs,d4,d5,d6,d7,bl,blpol
LiquidCrystal_I2C lcd(0x27, 2, 1, 0, 4, 5, 6, 7, 3, POSITIVE);  // 設定 LCD I2C 位址

void setup() {
  Serial.begin(9600);
  lcd.begin(16, 2);      // 初始化 LCD，一行 16 的字元，共 2 行，預設開啟背光

  // 閃爍三次
  for(int i = 0; i < 3; i++) {
    lcd.backlight(); // 開啟背光
    delay(250);
    lcd.noBacklight(); // 關閉背光
    delay(250);
  }
  lcd.backlight();

  // 輸出初始化文字
  lcd.setCursor(0, 0);    // 設定游標位置在第一行行首
  lcd.print("Welcome!!"); // 印出文字
  delay(2000);
  lcd.clear();            //清空LCD
  lcd.print("MBL Present");
  delay(2000);

  //
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("A.baumannii ");
  lcd.setCursor(0, 1); // 設定游標位置在第一行行首
  lcd.print("Detector");
  delay(2000);
  lcd.clear();
}

void loop() {
  int pinRead0 = analogRead(inPin0);
  float pVolt0 = pinRead0 / 1024.0 * 5.0;
  lcd.setCursor(0, 0);
  lcd.print((millis()-6500)/1000);
  lcd.print(" sec");

  lcd.setCursor(0, 1);
  lcd.print("signal ");
  lcd.print(pVolt0);
  lcd.print(" V");
  delay(1000);
  
}
