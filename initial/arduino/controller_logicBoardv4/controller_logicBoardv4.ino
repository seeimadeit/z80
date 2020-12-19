#define SERIAL_TX_BUFFER_SIZE 2
#define SERIALPORT 1
#define VERSION "\nSerialPort Ready v0.0.0,Device id 0x01"
// IO device port 0x01


uint8_t character = 0; // character to send
int characterpause = 0;
#define keypressdelay  100
int xcontrol = 1; // xon=char(19), xoff=char(17). xcontrol=1 = enabled


#define DELAY 10
// CLK,WAIT arduino pins used

#define RESETZ80 8
#define WAIT 13
#define CLOCKIN 12
#define HASPOWER 11
#define IOREQ 42 // not used I hope
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
#define ACTIVE 40  // comes from GAL ATF16V8 (ACTIVE LOW)


#define DEBUG
#ifdef DEBUG
#define DWRITE(c) Serial.println(c)
#else
#define DWRITE(c)
#endif

void setup() {
  // put your setup code here, to run once:


  setMode(INPUT);
#ifdef DEBUG
  Serial.begin(115200);
  while (!Serial) ;
  DWRITE(VERSION);
#endif
  pinMode(HASPOWER, INPUT);
  pinMode(INT, OUTPUT); digitalWrite(INT, HIGH);
  pinMode(IOREQ, INPUT);
  pinMode(M1, INPUT);
  pinMode(IOREAD, INPUT);
  pinMode(ACTIVE, INPUT);
  pinMode(CLOCKIN, INPUT);
  digitalWrite(WAIT, HIGH);

  DoRead(INPUT);


  DWRITE("Time setup complete");
  // reset the z80
  pinMode(RESETZ80, OUTPUT);
  digitalWrite(RESETZ80, LOW);
  for (int i = 0; i < 20; i++)
    delay(2);
  digitalWrite(RESETZ80, HIGH);
  pinMode(RESETZ80, INPUT);
  DWRITE("Reset complete");

}

void setMode(uint8_t mode)
{
  //pinMode(CLK, mode);
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


}

/* write to the databus */
void write(uint8_t c)
{
  DoRead(OUTPUT);
  //DWRITE("busWrite"); DWRITE(c);
  for (int i = 0; i < 8; i++)
  {
    digitalWrite(D7 - i, (c >> 7));
    //DWRITE((c >> 7));
    c = c << 1;
  }
}

void readchannel( uint8_t *_c)
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
  *_c = c;
}


uint8_t c = 0;
void handleioacknowledge()
{

  /*    Serial.print("ioreq="); Serial.print(ioreq);
      Serial.print(",Active="); Serial.print(digitalRead(ACTIVE));
      Serial.print(",M1="); Serial.println(m1);
  */
  digitalWrite(INT, HIGH);


  if (character != 0  ) { // this is for interrupt mode 1 or mode 2
    write(2); // vector for mode 2, note this code will also work with mode 1

    // test ioreq pin
    if (digitalRead(IOREQ) == HIGH) {
      Serial.print("ooops");
    }
    int ccc = 0;
    digitalWrite(WAIT, LOW);
    // may need a pause
    // while (digitalRead(ACTIVE) == LOW); // wait for the low state to change
    while (digitalRead(IOREQ) == LOW) ccc++; // wait for the low state to change
    digitalWrite(WAIT, HIGH);
    DoRead(INPUT);
    Serial.println(ccc);

  } else {
    Serial.print("hey whats going on");
    write(2); // vector for mode 2, note this code will also work with mode 1


    digitalWrite(WAIT, LOW);
    // may need a pause
    while (digitalRead(IOREQ) == LOW); // wait for the low state to change
    digitalWrite(WAIT, HIGH);
    DoRead(INPUT);
  }
  //digitalWrite(WAIT, HIGH);


}


void handleiorequest()
{
  // only process when active = low


  bool IsRead = digitalRead(IOREAD);
  if (!IsRead) {
    readchannel(&c);
    if (c == 19) xcontrol = 0; // xoff - disable sending keystrokes - allow processor time to process
    if (c == 17) xcontrol = 1; // xon - enable sending keystrokes again - keyboard
    if (c == 0)
    {
      Serial.println("zero");
    } else {
      Serial.print((char)c);
    }

    digitalWrite(WAIT, LOW);
    // may need a pause
    while (digitalRead(ACTIVE) == LOW) ; // wait for the low state to change
    digitalWrite(WAIT, HIGH);

  } else {// !isread



    if (character == 0) character = '+';
    write(character);
    character = 0;

    digitalWrite(WAIT, LOW);
    // may need a pause

    while (digitalRead(ACTIVE) == LOW) ; // wait for the low state to change
    digitalWrite(WAIT, HIGH);
    DoRead(INPUT);

  }
}

void loop() {
  //digitalWrite(WAIT, LOW);
  int ioreq = digitalRead(IOREQ);

  int m1 = digitalRead(M1);

  if (ioreq == LOW && m1 == LOW) {
    handleioacknowledge();
  } else {

    int active = digitalRead(ACTIVE);
    if (active == LOW) {
      handleiorequest();

    } else {


      // if active low
    }

    // xon/xoff flow control
  } // intack
  //if (xcontrol == 1) {
  if (character == 0 && Serial.available()) {
    // discovered the z80 will just allow interrupts after interrupts therefore not allowing
    // the processor time to deal with the data. so we will not send keys without a pause between
    // each character.
    characterpause++;
    if (characterpause > keypressdelay)
    {
      characterpause = 0;
      character = Serial.read();

      digitalWrite(INT, LOW); // hold it low until we get a response.



    }
  }
  //}
  // change the current mode;
  setMode(digitalRead(HASPOWER));

} // void loop
