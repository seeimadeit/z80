#define VERSION "SD Card Reader v0.0.0, Device id = 0x05"

/* z80 out only*/
#define NOTHING 0
#define FILENAMECLEAR 1
#define OPEN 2
#define CLOSE 3
/*z80 out + in*/
#define FILENAMEAPPEND 4
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
#define RDWR 9 //comes from z80 _WR (write active low)
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

DoRead(INPUT);
  
}

void DoRead(uint8_t mode)
{
  pinMode(D0, mode);
  pinMode(D0, mode);
  pinMode(D0, mode);
  pinMode(D0, mode);
  pinMode(D0, mode);
  pinMode(D0, mode);
  pinMode(D0, mode);
  pinMode(D0, mode);

}

/* write to the databus */
void write(uint8_t c)
{
  DoRead(OUTPUT);
  // DWRITE("busWrite"); DWRITE(c);
  for (int i = 0; i < 8; i++)
  {
    digitalWrite(D7 - i, (c >> 7));
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
 
  DWRITE("received:"); DWRITE(c);
}

unsigned char WriteCmd(int command)
{
    int result = 0;
    switch (state)
    {
        case NOTHING:
        {
            switch (command)
            {
            case FILENAMECLEAR:
                index = 0;
                filename[index] = 0; 
                break;
            case FILENAMEAPPEND:
                state = FILENAMEAPPEND;
                break;
            case OPEN:
                file = SD.open(filename);
                break;
            case CLOSE:
                file.close();
                break;
            case READNEXTBYTE:
                state = READNEXTBYTE;
                break;
            case AVAILABLE:
                state = AVAILABLE;
                break;
            }
        }
        break;
        case FILENAMEAPPEND:
        {
            filename[index++] = command;
            filename[index] = 0;
            state = NOTHING;
        }   
        break;
        case AVAILABLE:
        {
            result = file.available();
            state = NOTHING;
        }
        break;
        case READNEXTBYTE:
        {
            result = file.read();
            state = NOTHING;
        }
        break;
    }
    return result;
}

void process()
{
digitalWrite(WAIT,LOW);
int isRead = digitalRead(RDWR);
if (!isRead) {
  uint8_t c=0;
  readchannel(&c);
  WriteCmd(c);
  DWRITE("state after"); DWRITE(state);
} else {
  
}

digitalWrite(WAIT,HIGH);
DoRead(INPUT);
}

void loop(void) {
  if (digitalRead(ACTIVE)==LOW)
  {
    DWRITE("ACTIVE");
    process();
  }
  
}
