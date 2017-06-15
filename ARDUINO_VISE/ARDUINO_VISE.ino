#include <VarSpeedServo.h> 



VarSpeedServo gripperServo;
VarSpeedServo hopperServo;




const int inByte = 0;         // incoming serial byte
const int FORWARD_PIN = 47;
const int REVERSE_PIN = 32;
const int SWITCH = 3;
const int HOPPER_PIN = 11;  //change this
const int GRIPPER_PIN = 6;
const int SINK_PIN = 63;
const int DRILL_PIN = 40;
const int BLOW_PIN = 66;

long CLOSE_TIME = 0

bool OPEN_STATE = false;
bool st = false;


void setup()
{
  // start serial port at 9600 bps:
  Serial.begin(115200);
  pinMode(FORWARD_PIN,OUTPUT);   // digital sensor is on digital pin 2
  pinMode(REVERSE_PIN,OUTPUT);
  pinMode(SINK_PIN, OUTPUT);
  pinMode(DRILL_PIN, OUTPUT);
  pinMode(BLOW_PIN, OUTPUT);
  pinMode(SWITCH,INPUT);
  digitalWrite(REVERSE_PIN,LOW);
  digitalWrite(FORWARD_PIN,LOW);
  digitalWrite(SINK_PIN,HIGH);
  digitalWrite(DRILL_PIN,HIGH);
  digitalWrite(BLOW_PIN, HIGH);
  while (true) {
        st = digitalRead(SWITCH);
        //Serial.println(st);
        if (st==HIGH){
          digitalWrite(FORWARD_PIN, HIGH);
          delay(10);
          }
        else{
          Serial.println("CLOSED");
          digitalWrite(FORWARD_PIN, LOW);
          break;
          }
        }
  establishContact();  // send a byte to establish contact until Processing responds 
}

void loop() {
  
  if (Serial.available() > 0) {
    // get incoming byte:
    int inByte = Serial.read();
    switch (inByte) {
    case 'O':
      Serial.print(inByte);
      Serial.println("OPENING");
      digitalWrite(REVERSE_PIN,HIGH);
      delay(9000);
      Serial.println("OPEN");
      digitalWrite(REVERSE_PIN,LOW);
      gripperServo.attach(GRIPPER_PIN);
      gripperServo.write(161, 100, false);
      break;
    
    case 'C':
      Serial.print(inByte);
      Serial.println("CLOSIING");
      CLOSE_TIME = millis() + 9000;
      while (true) {
        st = digitalRead(SWITCH);
        Serial.println(st);
        if (st==HIGH){
          digitalWrite(FORWARD_PIN, HIGH);
          delay(10);
          if (millis() > CLOSE_TIME){
            gripperServo.attach(GRIPPER_PIN);
            gripperServo.write(161, 100, false);
          }
        }
        else{
          Serial.println("CLOSED");
          digitalWrite(FORWARD_PIN, LOW);
          gripperServo.attach(GRIPPER_PIN);
          gripperServo.write(161, 100, false);
          break;
          }
        }
      
      break;
    
    case 'H':  //CYCLE HOPPER
      hopperServo.attach(HOPPER_PIN);
	  hopperServo.write(140, 155, true);
      delay(1000);
	  hopperServo.write(10, 155, true);
	  delay(1000);
	  hopperServo.write(140,155, true);
	  delay(1000);
	  hopperServo.detach();
	  break;
    
    case 'G':  //OPEN GRIPPER
      gripperServo.attach(GRIPPER_PIN);
      gripperServo.write(161, 100, false);
	  delay(500);
      break;
    
    case 'g':
      gripperServo.attach(GRIPPER_PIN);
      gripperServo.write(65, 100, false);
      delay(500);
      break;
    
    case 'D':
      digitalWrite(DRILL_PIN, LOW);
      Serial.println("DRILL ON");
      break;
    
    case 'd':
      digitalWrite(DRILL_PIN, HIGH);
      Serial.println("DRILL OFF");
      break;
      
    case 'S':
      digitalWrite(SINK_PIN, LOW);
      Serial.println("COUNTERSINK ON");
      break;
      
    case 's':
      digitalWrite(SINK_PIN, HIGH);
      Serial.println("COUNTERSINK OFF");
      break;
    
    case 'B':
      digitalWrite(BLOW_PIN, LOW);
      Serial.println("BLOWER ON");
      break;
    
    case 'b':
      digitalWrite(BLOW_PIN, HIGH);
      Serial.println("BLOWER OFF");
      break;  
        
    default:
      Serial.print(inByte);
      Serial.println(" not on the list");
    
    
    }
    
    
    
    
    
  }

}

void establishContact() {
 while (Serial.available() <= 0) {
      Serial.println("im there");   // send a capital A
      delay(300);
  }
}



