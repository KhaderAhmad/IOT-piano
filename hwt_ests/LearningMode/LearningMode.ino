///////// NOT WORKINGGGGGGGGGGGGGGGGGGGGGGGG


/***************************************************************************************************************************************************/
/*                                                    includes and defines                                                                         */
/***************************************************************************************************************************************************/
#include <WiFi.h>
#include <HTTPClient.h>
#include <Wire.h>
#include <Arduino.h>
#include <string.h>
#include "Adafruit_MPR121.h"
#include "driver/i2s.h"



//DEFINES:

#define I2S_WS  25  // LRC pin
#define I2S_SD  23  // DIN pin
#define I2S_SCK 26  // BCLK pin

#define SAMPLE_RATE 44100

#ifndef _BV
#define _BV(bit) (1 << (bit))
#endif


// VCC: Connect to 3.3V on the ESP32.
// GND: Connect to GND on the ESP32.
// SDA: Connect to GPIO 21 (I2C data line) on the ESP32.
// SCL: Connect to GPIO 22 (I2C clock line) on the ESP32.
// IRQ: Not necessary for basic functionality but can be connected to an interrupt pin on the ESP32 if needed for advanced features.


/***************************************************************************************************************************************************/
/*                                                         WIFI CONNECTION                                                                         */
/***************************************************************************************************************************************************/
#include <ESP32Firebase.h>
//#include <Arduino.h>
//#include <Adafruit_NeoPixel.h>
#define _SSID "jamila"          // Your WiFi SSID
#define _PASSWORD "12345678"      // Your WiFi Password
#define REFERENCE_URL "https://iot-pianos24-default-rtdb.asia-southeast1.firebasedatabase.app/"  // Your Firebase project reference url
#define FIREBASE_AUTH "AIzaSyBcIwws7MRvy8MOT7qeqCRUCMmY--rXLCw"


Firebase firebase(REFERENCE_URL);

void firebaseSetup()
{
  Serial.println("Connecting to WIFI:");
  WiFi.mode(WIFI_STA);
  WiFi.disconnect();
  delay(1000);

  // Connect to WiFi
  WiFi.begin(_SSID, _PASSWORD);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print("-");
  }
  Serial.println("Connected to WIFI");

  
}

int firebaseReadSongNum()
{
  int songNum =  firebase.getInt("songNum");
  Serial.print("SongNum is:");
  Serial.println(songNum);
  return songNum;
}

String firebaseReadSong(int songNum){
  String songStr = "/songs/song" + String(songNum);
  String song =  firebase.getString(songStr);
  Serial.print("Song is:");
  Serial.println(song);
  return song;
}


/***************************************************************************************************************************************************/
/*                                                         MPR121 setup                                                                         */
/***************************************************************************************************************************************************/
Adafruit_MPR121 cap = Adafruit_MPR121();



// Keeps track of the last pins touched
// so we know when buttons are 'released'
uint16_t lasttouched = 0;
uint16_t currtouched = 0;


void mprSetup(){
  Serial.println("Adafruit MPR121 Capacitive Touch sensor test");
 
  // Default address is 0x5A, if tied to 3.3V its 0x5B
  // If tied to SDA its 0x5C and if SCL then 0x5D
  if (!cap.begin(0x5A)) {
    Serial.println("MPR121 not found, check wiring?");
    while (1);
  }
  Serial.println("MPR121 found!");

}

/***************************************************************************************************************************************************/
/*                                                         DAC Amplifier setup                                                                         */
/***************************************************************************************************************************************************/

size_t bytes_written;
const int sample_count = 1000;
int16_t samples[sample_count];


void dacSetup(){
  // Configure I2S
  i2s_config_t i2s_config = {
    .mode = (i2s_mode_t)(I2S_MODE_MASTER | I2S_MODE_TX),
    .sample_rate = 44100,
    .bits_per_sample = I2S_BITS_PER_SAMPLE_16BIT,
    .channel_format = I2S_CHANNEL_FMT_RIGHT_LEFT,
    .communication_format = I2S_COMM_FORMAT_I2S,
    .intr_alloc_flags = 0,
    .dma_buf_count = 8,
    .dma_buf_len = 64,
    .use_apll = false,
    .tx_desc_auto_clear = true,
    .fixed_mclk = 0
  };

  i2s_pin_config_t pin_config = {
    .bck_io_num = I2S_SCK,
    .ws_io_num = I2S_WS,
    .data_out_num = I2S_SD,
    .data_in_num = I2S_PIN_NO_CHANGE
  };

  // Install and start I2S driver
  i2s_driver_install(I2S_NUM_0, &i2s_config, 0, NULL);
  i2s_set_pin(I2S_NUM_0, &pin_config);
}




/***************************************************************************************************************************************************/
/*                                                              sound functions                                                                              */
/***************************************************************************************************************************************************/



void playDoTone(){
  float frequency = 261.5;
  for (int i = 0; i < sample_count; i++) {
    samples[i] = (int16_t)(32767.0 * cos(2.0 * PI * frequency * ((float)i / 44100.0)));
  }
}

void playReTone(){
  float frequency = 293.5;
  for (int i = 0; i < sample_count; i++) {
    samples[i] = (int16_t)(32767.0 * cos(2.0 * PI * frequency * ((float)i / 44100.0)));
  }
}
void playMiTone(){
  float frequency = 329.5;
  for (int i = 0; i < sample_count; i++) {
    samples[i] = (int16_t)(32767.0 * cos(2.0 * PI * frequency * ((float)i / 44100.0)));
  }
}
void playFaTone(){
  float frequency = 349.00;
  for (int i = 0; i < sample_count; i++) {
    samples[i] = (int16_t)(32767.0 * sin(2.0 * PI * frequency * ((float)i / 44100.0)));
  }
}
void playSolTone(){
  float frequency = 392.00;
  for (int i = 0; i < sample_count; i++) {
    samples[i] = (int16_t)(32767.0 * sin(2.0 * PI * frequency * ((float)i / 44100.0)));
  }
}
void playLaTone(){
  float frequency = 440.00;
  for (int i = 0; i < sample_count; i++) {
    samples[i] = (int16_t)(32767.0 * sin(2.0 * PI * frequency * ((float)i / 44100.0)));
  }
}
void playTiTone(){
  float frequency = 494.00;
  for (int i = 0; i < sample_count; i++) {
    samples[i] = (int16_t)(32767.0 * sin(2.0 * PI * frequency * ((float)i / 44100.0)));
  }
}
void playDo2Tone(){
  float frequency = 523.00;
  for (int i = 0; i < sample_count; i++) {
    samples[i] = (int16_t)(32767.0 * sin(2.0 * PI * frequency * ((float)i / 44100.0)));
  }
}
void stopTone(){
  float frequency = 0.0;
  for (int i = 0; i < sample_count; i++) {
    samples[i] = (int16_t)(32767.0 * sin(2.0 * PI * frequency * ((float)i / 44100.0)));
  }
}

void playSoundByChar(char num){

  switch(num){
    case 'A': playDoTone();
    break;
    case 'B': playReTone();
    break;
    case 'C': playMiTone();
    break;
    case 'D': playFaTone();
    break;
    case 'E': playSolTone();
    break;
    case 'F': playLaTone();
    break;
    case 'G': playTiTone();
    break;
    case 'H': playDo2Tone();
    break;
    default: stopTone();
    break;
  }

}


int getNumForChar(char num){
  switch(num){
    case 'A': return 1;
    break;
    case 'B': return 2;
    break;
    case 'C': return 3;
    break;
    case 'D': return 4;
    break;
    case 'E': return 5;
    break;
    case 'F': return 6;
    break;
    case 'G': return 7;
    break;
    case 'H': return 8;
    break;
    default: return 0;
    break;
  }

}


void playSongByNum(int num){
  bool correct = true;
  String song = firebaseReadSong(num);
  for(int i =0; i< song.length(); i++){
    playSoundByChar(song[i]);
    for (int i = 0; i < 10; i++) {
  i2s_write(I2S_NUM_0, samples, sizeof(samples), &bytes_written, portMAX_DELAY);
  }
  correct = waitForTouchAndCheckIfCorrect(song[i]);
  if(!correct){
    return;
  }
  }
}


bool waitForTouchAndCheckIfCorrect(char note){
  currtouched = cap.touched();
  while (!(currtouched & _BV(0)) && (lasttouched & _BV(0)) ) {
    delay(200);
  }
  for (uint8_t i=0; i<12; i++) {
    // it if is touched and wasnt touched before, alert!
    if ((currtouched & _BV(i)) && !(lasttouched & _BV(i)) ) {
      Serial.print(i); Serial.println(" touched");
      if(note != getNumForChar(i)){
          return false;
      }
    }
    // // if it was touched and now isnt, alert!
    // if (!(currtouched & _BV(i)) && (lasttouched & _BV(i)) ) {
    //   Serial.print(i); Serial.println(" released");
    //   stopTone();
    // }
  }
  // reset our state
  lasttouched = currtouched;
}



/***************************************************************************************************************************************************/
/*                                                              setup                                                                              */
/***************************************************************************************************************************************************/

void setup() {
 Serial.begin(115200);


  while (!Serial) { // needed to keep leonardo/micro from starting too fast!
    delay(10);
  }
 

  firebaseSetup();

  delay(1000);

  mprSetup();

  delay(1000);

  dacSetup();

}


/***************************************************************************************************************************************************/
/*                                                                loop                                                                             */
/***************************************************************************************************************************************************/

void loop() {
  Serial.println("here");

  

  int num = firebaseReadSongNum();
  String song1 = firebaseReadSong(1);
  playSongByNum(1);
  
  
  String song2 = firebaseReadSong(2);



  // comment out this line for detailed data from the sensor!
  return;
}
