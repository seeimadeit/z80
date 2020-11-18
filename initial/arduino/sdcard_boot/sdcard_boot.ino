#define VERSION "SD Card Reader v0.0.0, Device id = 0x05"

/* z80 out only*/
#define NOTHING 0
#define FILENAMECLEAR 1
#define OPEN 2
#define CLOSE 3
#define FILENAMEAPPEND 4
/*z80 out + in*/
#define READNEXTBYTE 5
#define AVAILABLE 6

volatile byte filename[12];
volatile uint8_t index=0;
volatile int state = NOTHING;

/*
    SD card attached to SPI bus as follows:
 ** SDO - pin 11 on Arduino Uno/Duemilanove/Diecimila
 ** SDI - pin 12 on Arduino Uno/Duemilanove/Diecimila
 ** CLK - pin 13 on Arduino Uno/Duemilanove/Diecimila
 ** CS - depends on your SD card shield or module.
        Pin 10 used here for consistency with other Arduino examples
*/
/*
#define CLK 12
#define WAIT 13
#define IOREQ 3
#define M1 4
#define IOREAD 2
*/



#define ACTIVE 2 // comes from GAL ATF16V8 (ACTIVE LOW)
#define RDWR 7 //comes from z80 _WR (write active low)
#define WAIT 8 // active low

#define D7 4
#define D6 3
#define D5 A5
#define D4 A4
#define D3 A3
#define D2 A2
#define D1 A1
#define D0 A0




#define DEBUG
#ifdef DEBUG
#define DWRITE(c) Serial.println(c)
#else
#define DWRITE(c)
#endif

// include the SD library:
#include <SPI.h>
#include <SD.h>

File file;

// change this to match your SD shield or module;
// Default SPI on Uno and Nano: pin 10
// Arduino Ethernet shield: pin 4
// Adafruit SD shields and modules: pin 10
// Sparkfun SD shield: pin 8
// MKRZero SD: SDCARD_SS_PIN

const int chipSelect = 10;

void setup() {

  // Open serial communications and wait for port to open:

#ifdef DEBUG
  Serial.begin(9600);
  while (!Serial) ;
  Serial.println(VERSION);
#endif

  if (!SD.begin(chipSelect))
  {
    Serial.println("SD Card failed");
  }
pinMode(ACTIVE,INPUT);
pinMode(RDWR,INPUT);
pinMode(WAIT,OUTPUT);
digitalWrite(WAIT,HIGH);
digitalWrite(WAIT,LOW);
digitalWrite(WAIT,HIGH);
DoRead(INPUT);
  DWRITE("Ready");
}

void DoRead(uint8_t mode)
{
  pinMode(D0, mode);
  pinMode(D1, mode);
  pinMode(D2, mode);
  pinMode(D3, mode);
  pinMode(D4, mode);
  pinMode(D5, mode);
  pinMode(D6, mode);
  pinMode(D7, mode);

}

/* write to the databus */
void write(uint8_t c)
{
  DoRead(OUTPUT);
//  DWRITE("busWrite"); DWRITE(c);
  for (int i = 0; i < 8; i++)
  {
    int x = (c>>7);
  //  Serial.print(x);
    switch (i)
    {
      case 7: digitalWrite(D0,x);break;
      case 6: digitalWrite(D1,x);break;
      case 5: digitalWrite(D2,x);break;
      case 4: digitalWrite(D3,x);break;
      case 3: digitalWrite(D4,x);break;
      case 2: digitalWrite(D5,x);break;
      case 1: digitalWrite(D6,x);break;
      case 0: digitalWrite(D7,x);break;
    }
//    DWRITE("DONE WRITE");
    //digitalWrite(D7 - i, (c >> 7));
    //Serial.print(D7-i); Serial.print(":");Serial.println(c>>7);
    c = c << 1;
  }
}

void readchannel( uint8_t *_c)
{
  // problem with compiler not setting variables. so needed to create
  // local variables here. argggg
  uint8_t c = 0;

  DoRead(INPUT);
  c = (c << 1) | digitalRead(D7);
  c = (c << 1) | digitalRead(D6);
  c = (c << 1) | digitalRead(D5);
  c = (c << 1) | digitalRead(D4);
  c = (c << 1) | digitalRead(D3);
  c = (c << 1) | digitalRead(D2);
  c = (c << 1) | digitalRead(D1);
  c = (c << 1) | digitalRead(D0);



  *_c = c;
 
 // DWRITE("received:"); DWRITE(c);
}

unsigned char WriteCmd(int command)
{
    uint8_t result = 0;
    switch (state)
    {
        case NOTHING:
        {
            switch (command)
            {
            case FILENAMECLEAR:
            file.close();
   //         DWRITE("FILENAMECLEAR");
                index = 0;
                filename[index] = 0; 
                break;
            case FILENAMEAPPEND:
     //       DWRITE("FILENAMEAPPEND");
                state = FILENAMEAPPEND;
                break;
            case OPEN:
    //        DWRITE("OPEN"); DWRITE((char*)filename); DWRITE("****");
                file = SD.open(filename);
                state=OPEN;
                break;
            case CLOSE:
    //        DWRITE("CLOSE");
               if (file) file.close();
                break;
            case READNEXTBYTE:
     //       DWRITE("READNEXTBYTE");
                state = READNEXTBYTE;
                break;
            case AVAILABLE:
      //      DWRITE("AVAILABLE");
                state = AVAILABLE;
                break;
            }
        }
        break;
        case OPEN:
          result = (file)?1:0;
          state=NOTHING;
          break;
        case FILENAMEAPPEND:
        {
     //     DWRITE("DOING APPEND"); DWRITE((char)command); DWRITE("----");
            filename[index++] = command;
            filename[index] = 0;
            state = NOTHING;
        }   
        break;
        case AVAILABLE:
        {
          
            result = (file.available())?1:0;
            //DWRITE("DOING AVAILABLE"); DWRITE(result); DWRITE("++++");
            state = NOTHING;
        }
        break;
        case READNEXTBYTE:
        {
            result = file.read();
     //       DWRITE("DOING READNEXTBYTE"); DWRITE((char)result); DWRITE("====");
         
            state = NOTHING;
        }
        break;
    }
    return result;
}

void process()
{

 // uint8_t c=0;
 // readchannel(&c);DWRITE("GOT "); Serial.println(c,HEX);
int isRead = digitalRead(RDWR);
//DWRITE("RDWR"); DWRITE(isRead);
if (!isRead) {
  
  uint8_t c=0;
  readchannel(&c);
  //DWRITE("GOT READ"); Serial.println(c,HEX);
  WriteCmd(c);
 // DWRITE("state after"); DWRITE(state);
} else {
  //DWRITE("GOT WRITE");
  uint8_t t = WriteCmd(0);
  //Serial.println(t,BIN);
  write(t);
  //DWRITE("done");
}

digitalWrite(WAIT,HIGH);
waitForNotActive();
DoRead(INPUT);
}
void waitForNotActive()
{   
  while (digitalRead(ACTIVE)==LOW) ;
  //Serial.print("*A*");
}
void loop(void) {
  if (digitalRead(ACTIVE)==LOW)
  {
 digitalWrite(WAIT,LOW);
    process();
  }
  //int isRead = digitalRead(RDWR);
 // if (isRead==LOW) {Serial.print("xRDWR"); Serial.print(isRead);}
}
