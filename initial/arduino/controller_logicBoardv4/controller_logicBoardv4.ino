#define SERIAL_TX_BUFFER_SIZE 2
#define SERIALPORT 1
#define VERSION "\nSerialPort Ready v0.0.0,Device id 0x01"
// IO device port 0x01


uint8_t character = 0; // character to send
int characterpause = 0;
#define keypressdelay  100
int xcontrol = 1; // xon=char(19), xoff=char(17). xcontrol=1 = enabled

bool clockset = LOW;
#define CLK 12

#define DELAY 10
// CLK,WAIT arduino pins used

#define RESETZ80 8
#define WAIT 13
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
void setuptimer()
{
  //https://www.instructables.com/Arduino-Timer-Interrupts/
  cli();//stop interrupts

  //set timer0 interrupt at 2kHz
  TCCR0A = 0;// set entire TCCR2A register to 0
  TCCR0B = 0;// same for TCCR2B
  TCNT0  = 0;//initialize counter value to 0
  // set compare match register for 2khz increments
  OCR0A = 25;// = (16*10^6) / (2000*64) - 1 (must be <256)
  // turn on CTC mode
  TCCR0A |= (1 << WGM01);
  // Set CS01 and CS00 bits for 64 prescaler
  TCCR0B |= (1 << CS01) | (1 << CS00);
  // enable timer compare interrupt
  TIMSK0 |= (1 << OCIE0A);
  sei();//allow interrupts
}
ISR(TIMER0_COMPA_vect) { //timer0 interrupt 2kHz toggles pin CLK
  //generates pulse wave of frequency 2kHz/2 = 1kHz (takes two cycles for full wave- toggle high then toggle low)
  //DWRITE("clock::"); DWRITE(clockset);
  if (!clockset) {
    digitalWrite(CLK, HIGH);
    clockset = HIGH;
  }
  else {
    digitalWrite(CLK, LOW);
    clockset = LOW;
  }
}
void setup() {
  // put your setup code here, to run once:

  setMode(INPUT);
#ifdef DEBUG
  Serial.begin(9600);
  while (!Serial) ;
  DWRITE(VERSION);
#endif
  pinMode(HASPOWER, INPUT);
  pinMode(INT, OUTPUT); digitalWrite(INT, HIGH);
  pinMode(IOREQ, INPUT);
  pinMode(M1, INPUT);
  pinMode(IOREAD, INPUT);
  pinMode(ACTIVE, INPUT);
  digitalWrite(WAIT, HIGH);
  DoRead(INPUT);
  DWRITE("time setup");
  setuptimer();

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


void loop() {
  int ioreq = digitalRead(IOREQ);
  int active = digitalRead(ACTIVE);
  int m1 = digitalRead(M1);
  //uint8_t c = 0;
  //readchannel(&c);
  /*     Serial.print("ioreq=");Serial.print(ioreq);
       Serial.print(",Active=");Serial.print(active);
       Serial.print(",M1=");Serial.println(m1);
  */
  if (ioreq == LOW && m1 == LOW) {

    if (character != 0 ) { // this is for interrupt mode 1 or mode 2
      digitalWrite(INT, HIGH); // remove the interrupt flag.
      write(2); // vector for mode 2, note this code will also work with mode 1
      digitalWrite(WAIT, HIGH);
      while (digitalRead(ACTIVE) == LOW); // wait for the low state to change
      DoRead(INPUT);
    }
  } else {
    if (active == LOW) {
      digitalWrite(WAIT, LOW);
      // only process when active = low
      uint8_t c = 0;
      readchannel(&c);

      bool IsRead = digitalRead(IOREAD);
      if (!IsRead) {

        if (c == 19) xcontrol = 0; // xoff - disable sending keystrokes - allow processor time to process
        if (c == 17) xcontrol = 1; // xon - enable sending keystrokes again - keyboard

        Serial.print((char)c);
        digitalWrite(WAIT, HIGH);
        while (digitalRead(ACTIVE) == LOW); // wait for the low state to change
      } else {// !isread

        if (character != 0) {
          digitalWrite(WAIT, LOW);

          write(character);
          character = 0;
        } // !isread
        digitalWrite(WAIT, HIGH);
        while (digitalRead(ACTIVE) == LOW); // wait for the low state to change
        DoRead(INPUT);
      }

    }
    // xon/xoff flow control
    if (xcontrol == 1) {
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
    }
    // change the current mode;
    setMode(digitalRead(HASPOWER));
  } // intack
} // void loop
