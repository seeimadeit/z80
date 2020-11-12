#define VERSION "\nReady v0.ad"
int capture = 0;
volatile boolean captured = false;
volatile uint8_t device = 0;

volatile int character = 0; // the character we want to send to the z80

int cycledsinceio=0;

// debouncecycles - number of cycles before a button press is recongnized
#define DEBOUNCECYCLES 2
#define SUPPLYCLK
#define DELAY 0
// PLAY,STEP,CLK,WAIT arduino pins used
//#define PLAY 6
//#define STEP 7
#define CLK 12
#define WAIT 13
#define HASPOWER 11
#define IOREQ 3
#define M1 4
#define IOREAD 2
#define INT 5
#define D0 22
#define D1 23
#define D2 24
#define D3 25
#define D4 26
#define D5 27
#define D6 28
#define D7 29
#define I0 40
#define I1 41
#define I2 42
#define I3 43
#define I4 44
#define I5 45
#define I6 46
#define I7 47


#define DEBUG
#ifdef DEBUG
#define DWRITE(c) Serial.println(c)
#else
#define DWRITE(c)
#endif

void setup() {
  // put your setup code here, to run once:

  setMode(INPUT);
//  pinMode(STEP, INPUT_PULLUP);
 // pinMode(PLAY, INPUT_PULLUP);
  pinMode(HASPOWER, INPUT);
  pinMode(INT, OUTPUT); digitalWrite(INT, HIGH);// DWRITE("INT HIGH");
  pinMode(IOREQ, INPUT);
  pinMode(M1, INPUT);
  pinMode(IOREAD, INPUT);

  DoRead(INPUT);
  pinMode(I0, INPUT);
  pinMode(I1, INPUT);
  pinMode(I2, INPUT);
  pinMode(I3, INPUT);
  pinMode(I4, INPUT);
  pinMode(I5, INPUT);
  pinMode(I6, INPUT);
  pinMode(I7, INPUT);

#ifdef DEBUG
  Serial.begin(9600);
  while (!Serial) ;
  DWRITE(VERSION);
#endif

}
void clock(bool half)
{

  digitalWrite(CLK, HIGH);
  delay(DELAY);

  digitalWrite(CLK, LOW);
  delay(DELAY);

}


void createInterruptRequest()
{
  digitalWrite(INT, LOW);
  for (int b = 0 ; b < 4; b++) {
    clock(false);
  }
  digitalWrite(INT, HIGH); 
}
void setMode(uint8_t mode)
{
  pinMode(CLK, mode);
  pinMode(WAIT, mode);

}
/* change the direction of IO pins for reading or writing */
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

  pinMode(I0, mode);
  pinMode(I1, mode);
  pinMode(I2, mode);
  pinMode(I3, mode);
  pinMode(I4, mode);
  pinMode(I5, mode);
  pinMode(I6, mode);
  pinMode(I7, mode);

}
void write(uint8_t c)
{
  // DWRITE("busWrite"); DWRITE(c);
  for (int i = 0; i < 8; i++)
  {
    digitalWrite(D7 - i, (c >> 7));
    c = c << 1;

  }
}


void readchannel(uint8_t *_d, uint8_t *_c)
{
  uint8_t c = 0;
  uint8_t d = 0;
  c = (c << 1) | digitalRead(D7);
  c = (c << 1) | digitalRead(D6);
  c = (c << 1) | digitalRead(D5);
  c = (c << 1) | digitalRead(D4);
  c = (c << 1) | digitalRead(D3);
  c = (c << 1) | digitalRead(D2);
  c = (c << 1) | digitalRead(D1);
  c = (c << 1) | digitalRead(D0);

  d = (d << 1) | digitalRead(I7);
  d = (d << 1) | digitalRead(I6);
  d = (d << 1) | digitalRead(I5);
  d = (d << 1) | digitalRead(I4);
  d = (d << 1) | digitalRead(I3);
  d = (d << 1) | digitalRead(I2);
  d = (d << 1) | digitalRead(I1);
  d = (d << 1) | digitalRead(I0);

  *_c = c;
  *_d = d;
}

void IORequest()
{

  int m1 = digitalRead(M1);
  int ioreq = digitalRead(IOREQ);

  bool InterruptACK =  (m1 == LOW && ioreq == LOW) ? HIGH : LOW;

  if (InterruptACK)
  {

    /*
      // read from z80 = low, write to z80 = high;
      this appears odd. the _WR pin from the Z80 is connected the arduino IOREAD. so if the _WR is low
      it means the z80 is trying to write into the arduino.
    */

    //DWRITE("interrupt Write to z80 x ");
    DoRead(OUTPUT);

    digitalWrite(I7, 0);
    digitalWrite(I6, 0);
    digitalWrite(I5, 0);
    digitalWrite(I4, 0);
    digitalWrite(I3, 0);
    digitalWrite(I2, 0);
    digitalWrite(I1, 0);
    digitalWrite(I0, 0);

    uint8_t vector = 0; // default vector is to receive data from z80 for display
    if (character == '~') {
        character=0;
      vector = 2; // vector is to write character to the z80
    }

    write(vector);

    clock(false); clock(false); clock(false);


    DoRead(INPUT);


  } else {
    bool IsRead = digitalRead(IOREAD);

    if (!IsRead) {

      //    DWRITE("Read from Z80");
      DoRead(INPUT);
      //  if (captured == false) {
      uint8_t d = 0;
      uint8_t c = 0;
      readchannel(&d, &c);

      capture = c;
      device = d;


      captured = true;
      // after the read perform 2 more clock cycles
      clock(false); clock(false);
      // }
    } else {

      DoRead(OUTPUT);
      write(character);
      character = 0;

      clock(false);
      DoRead(INPUT);
    }
  } // end interrupt write

  return ;
}
void loop() {
  // clock signal
  clock(false);

  if (digitalRead(IOREQ) == LOW)
  {

    IORequest();
    if (captured)
    {
      captured = false;

      Serial.print((char)capture);
    }
    cycledsinceio=0;
  } else {

  cycledsinceio++;
  // read from terminal
  if (Serial.available() > 0 && cycledsinceio>23 ) {

    if (character == 0) {
      character = Serial.read();

      if (character == 10) // ignore LF for now
      {
        character = 0; //DWRITE("LF");
        createInterruptRequest();
      } else {

        // we have data to time to signal the z80 with an interrupt request and wait for the INTACK */

        createInterruptRequest();
      } // characer 10

    }
  }

  }
  digitalWrite(WAIT, HIGH);



  // change the current mode;
  setMode(digitalRead(HASPOWER));


}
