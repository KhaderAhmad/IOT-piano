#include <WiFi.h>
#include <HTTPClient.h>
#include <Wire.h>
#include <Arduino.h>
#include <string.h>
#include "Adafruit_MPR121.h"
#include "driver/i2s.h"

// Defines
#define I2S_WS  25  // LRC pin
#define I2S_SD  23  // DIN pin
#define I2S_SCK 26  // BCLK pin
#define SAMPLE_RATE 44100

#ifndef _BV
#define _BV(bit) (1 << (bit))
#endif

// WiFi and Firebase setup
#include <ESP32Firebase.h>
#define _SSID "jamila"          // Your WiFi SSID
#define _PASSWORD "12345678"    // Your WiFi Password
#define REFERENCE_URL "https://ass2-cb1cb-default-rtdb.firebaseio.com/"
#define FIREBASE_AUTH "AIzaSyB1GPXvfeC1zr0cQ_-go7AmLtPTyiZrPR0"

Firebase firebase(REFERENCE_URL);

void firebaseSetup() {
  Serial.println("Connecting to WIFI:");
  WiFi.mode(WIFI_STA);
  WiFi.disconnect();
  delay(1000);
  WiFi.begin(_SSID, _PASSWORD);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print("-");
  }
  Serial.println("Connected to WIFI");
}

int firebaseReadSongNum() {
  int songNum = firebase.getInt("songNum");
  Serial.print("SongNum is:");
  Serial.println(songNum);
  return songNum;
}

String firebaseReadSong(int songNum) {
  String songStr = "/songs/song" + String(songNum);
  String song = firebase.getString(songStr);
  Serial.print("Song is:");
  Serial.println(song);
  return song;
}

// MPR121 setup
Adafruit_MPR121 cap = Adafruit_MPR121();
uint16_t lasttouched = 0;
uint16_t currtouched = 0;

void mprSetup() {
  Serial.println("Adafruit MPR121 Capacitive Touch sensor test");
  if (!cap.begin(0x5A)) {
    Serial.println("MPR121 not found, check wiring?");
    while (1);
  }
  Serial.println("MPR121 found!");
}

// DAC Amplifier setup
size_t bytes_written;
const int sample_count = 256; // Adjust sample count if needed
int16_t samples[sample_count];

void dacSetup() {
  i2s_config_t i2s_config = {
    .mode = (i2s_mode_t)(I2S_MODE_MASTER | I2S_MODE_TX),
    .sample_rate = SAMPLE_RATE,
    .bits_per_sample = I2S_BITS_PER_SAMPLE_16BIT,
    .channel_format = I2S_CHANNEL_FMT_RIGHT_LEFT,
    .communication_format = I2S_COMM_FORMAT_I2S_MSB,
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

  i2s_driver_install(I2S_NUM_0, &i2s_config, 0, NULL);
  i2s_set_pin(I2S_NUM_0, &pin_config);
}

// Sound functions
void generateTone(float frequency) {
  for (int i = 0; i < sample_count; i++) {
    samples[i] = (int16_t)(32767.0 * sin(2.0 * PI * frequency * ((float)i / SAMPLE_RATE)));
  }
}

void playSoundByChar(char note) {
  switch(note) {
    case 'A': generateTone(261.63); break; // Do
    case 'B': generateTone(293.66); break; // Re
    case 'C': generateTone(329.63); break; // Mi
    case 'D': generateTone(349.23); break; // Fa
    case 'E': generateTone(392.00); break; // Sol
    case 'F': generateTone(440.00); break; // La
    case 'G': generateTone(493.88); break; // Ti
    case 'H': generateTone(523.25); break; // Do (higher octave)
    default: generateTone(0); break;       // Silence
  }
}

int getNumForChar(char note) {
  switch(note) {
    case 'A': return 0;
    case 'B': return 1;
    case 'C': return 2;
    case 'D': return 3;
    case 'E': return 4;
    case 'F': return 5;
    case 'G': return 6;
    case 'H': return 7;
    default: return -1;
  }
}

void playSongByNum(int num) {
  String song = firebaseReadSong(num);
  for (int i = 0; i < song.length(); i++) {
    char note = song[i];
    if (note == ',') continue;
    playSoundByChar(note);
    for (int j = 0; j < 100; j++) {
      i2s_write(I2S_NUM_0, samples, sizeof(samples), &bytes_written, portMAX_DELAY);
    }
    delay(200);
  }
}

bool waitForTouchAndCheckIfCorrect(char note) {
  currtouched = cap.touched();
  while (!currtouched) {
    delay(100);
    currtouched = cap.touched();
  }
  for (uint8_t i = 0; i < 12; i++) {
    if ((currtouched & _BV(i)) && !(lasttouched & _BV(i))) {
      Serial.print(i); Serial.println(" touched");
      if (i != getNumForChar(note)) {
        Serial.println("Incorrect note");
        return false;
      }
    }
  }
  lasttouched = currtouched;
  Serial.println("Correct note");
  delay(1000);
  return true;
}

void setup() {
  Serial.begin(115200);
  while (!Serial) { delay(10); }
  firebaseSetup();
  delay(1000);
  mprSetup();
  delay(1000);
  dacSetup();
}

void loop() {
  Serial.println("Running");
  int num = firebaseReadSongNum();
  playSongByNum(num);
}
