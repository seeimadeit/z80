/*

  SD card test

  This example shows how use the utility libraries on which the'

  SD library is based in order to get info about your SD card.

  Very useful for testing a card when you're not sure whether its working or not.

  Pin numbers reflect the default SPI pins for Uno and Nano models

  The circuit:

    SD card attached to SPI bus as follows:

 ** SDO - pin 11 on Arduino Uno/Duemilanove/Diecimila

 ** SDI - pin 12 on Arduino Uno/Duemilanove/Diecimila

 ** CLK - pin 13 on Arduino Uno/Duemilanove/Diecimila

 ** CS - depends on your SD card shield or module.

        Pin 10 used here for consistency with other Arduino examples

  created  28 Mar 2011

  by Limor Fried

  modified 24 July 2020

  by Tom Igoe

*/
/*
#define CLK 12
#define WAIT 13
#define HASPOWER 11
#define IOREQ 3
#define M1 4
#define IOREAD 2
*/

#define D7 9
#define D6 8
#define D5 7
#define D4 6
#define D3 5
#define D2 4
#define D1 3
#define D0 2


// include the SD library:
#include <SPI.h>
#include <SD.h>

File readfile;

// change this to match your SD shield or module;
// Default SPI on Uno and Nano: pin 10
// Arduino Ethernet shield: pin 4
// Adafruit SD shields and modules: pin 10
// Sparkfun SD shield: pin 8
// MKRZero SD: SDCARD_SS_PIN

const int chipSelect = 10;

void setup() {

  // Open serial communications and wait for port to open:

  Serial.begin(9600);

  while (!Serial) {

    ; // wait for serial port to connect. Needed for native USB port only

  }
  Serial.println("hello");

  if (!SD.begin(chipSelect))
  {
    Serial.println("SD Card failed");
  }

  readfile=SD.open("RAM");
  if (!readfile) 
    Serial.println("oops ROM not found");
  while (readfile.available())
  {
    Serial.println(readfile.read(),HEX);
  }
  readfile.close();
}

void loop(void) {
}
