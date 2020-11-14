#define SERIALPORT 1
#define VERSION "\nSerialPort Ready v0.0.0,Device id 0x01"
// IO device port 0x01

int capture = 0;
boolean captured = false;
int character = 0; // the character we want to send to the z80

int iostate = 0; // tracks the initiated interrupt we created
int cycledsinceio = 0;

#define DELAY 0
// CLK,WAIT arduino pins used

#define RESETZ80 8
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

  // reset the z80
  pinMode(RESETZ80,OUTPUT);
  digitalWrite(RESETZ80,LOW);
  for (int i=0; i < 4;i++)
    clock(false);
  digitalWrite(RESETZ80,HIGH);
  pinMode(RESETZ80,INPUT);
}
void clock(bool half)
{
  digitalWrite(CLK, HIGH);
  delay(DELAY);
  digitalWrite(CLK, LOW);
  delay(DELAY);
}

/* when we create an interrupt request we can't process any keypress until
    the interrupt has been serviced. to ensure that happens we set the iostate
    flag. this flag it cleared after the io request has been acknowledged and
    the output has been written to the z80
*/
void createInterruptRequest()
{
  digitalWrite(INT, LOW);
  for (int b = 0 ; b < 4; b++) {
    clock(false);
  }
  digitalWrite(INT, HIGH);
  iostate = 1;
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


void readchannel(uint8_t *_d, uint8_t *_c)
{
  // problem with compiler not setting variables. so needed to create
  // local variables here. argggg
  uint8_t c = 0;
  uint8_t d = 0;
  DoRead(INPUT);
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
  // DWRITE("Device:"); DWRITE(d);
}

void performIO(uint8_t c)
{
  bool IsRead = digitalRead(IOREAD);
  if (!IsRead) {
    // DWRITE("Read from Z80");
    capture = c;
    captured = true;
    // after the read perform 2 more clock cycles
    clock(false); clock(false);
    if (iostate == 3) {
      // this can only happen if we initiated the ioreq
      iostate = 4;
    }
    // }
  } else {
    /* before we write the data we should validate the IO address but we don't do that yet. oops*/
    if (iostate == 2) {
      // we can only write the data the iostate is 2 because that tells me
      // we initiated the ioreq
      //DWRITE("Write to Z80");
      write(character);
      // after the character has been sent we clear it out.
      character = 0;

      clock(false);
      DoRead(INPUT);
      iostate = 3;
    } // iostate 2
  }

}

void IORequest()
{
  int m1 = digitalRead(M1);
  int ioreq = digitalRead(IOREQ);

  bool InterruptACK =  (m1 == LOW && ioreq == LOW) ? HIGH : LOW;

  // if we do get an interrupt ack when we didnt ask for it than it's not ours and we should
  // ignore it. so we check the iostate to see it we should respond
  // *****
  if (InterruptACK && iostate == 1)
  {
    /*
      // read from z80 = low, write to z80 = high;
      this appears odd. the _WR pin from the Z80 is connected the arduino IOREAD. so if the _WR is low
      it means the z80 is trying to write into the arduino.
    */
    /* during an interrupt ack,
          reading a0-a7 will return address of the current PC
          reading d0-d7 will return the data at the address of PC
          so there's no point in reading these values.

        uint8_t d = 0;
          uint8_t c = 0;
          readchannel(&d, &c);
          DWRITE("****");
        DWRITE(d); DWRITE(c);

    */

    //DWRITE("interrupt ack ");
    uint8_t vector = 2; // mode 2 interrupt vector.
    write(vector);
    clock(false);
    // set it back to input or we will be writing data on who knows what.
    DoRead(INPUT);
    iostate = 2;

  } else {

    uint8_t d = 0;
    uint8_t c = 0;
    readchannel(&d, &c);

    if (d == SERIALPORT)
    {
      /* before we read the data we should validate the IO address*/
      performIO(c);
    } // if device == serialport
  } // end interrupt write

  return ;
}
void loop() {
  // clock signal
  clock(false);

  if (digitalRead(IOREQ) == LOW)
  {
    IORequest();
  }
  if (captured)
  {
    captured = false;
    Serial.print((char)capture);
    iostate = 0;
  }
  if (iostate == 0)
  {
    // why not reset the count.
    if (cycledsinceio > 30000) cycledsinceio = 0;
  } else {
    cycledsinceio = 0;
  }
  cycledsinceio++;

  // read from terminal -
  // i don't understand why I need to wait for 26+ cycles before sending more data
  if (Serial.available() > 0 && cycledsinceio > 25 ) {
    if (character == 0) {
      character = Serial.read();
      createInterruptRequest();
    }
  }


  digitalWrite(WAIT, HIGH);



  // change the current mode;
  setMode(digitalRead(HASPOWER));


}
