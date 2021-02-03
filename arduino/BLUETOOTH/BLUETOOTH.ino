#include <SoftwareSerial.h> // use the software uart
#define inPin0 1
SoftwareSerial bluetooth(0, 1); // RX, TX

//for bluetooth
int start = 0;
int cancel = 0;

//for PD circuit
int pinRead0;
float pVolt0;
String voltage;
byte buf[5];   //buffer that store data

void setup() {
  bluetooth.begin(115200);
}

void loop() {
  //after start
  if (start == 1 && cancel == 0) {
    
    //get PD signal and sent 
    pinRead0 = analogRead(inPin0);
    pVolt0 = pinRead0 / 1024.0 * 5.0;
    voltage =  String(pVolt0, 2);  //turn data to string
    voltage.getBytes(buf,5);       //store data in buffer
    bluetooth.write(buf,4);        //send data through bluetooth
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
  else {
    if (bluetooth.available())
    {
      if (bluetooth.read() == 's') //s for start
      {
        //bluetooth.println("Start");
        start = 1;
        cancel = 0;
      }
    }
  }
}
