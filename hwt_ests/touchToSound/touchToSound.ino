#include <Wire.h>
#include "Adafruit_MPR121.h"
#include <Arduino.h>
#include "driver/i2s.h"

#define I2S_WS  25  // LRC pin
#define I2S_SD  23  // DIN pin
#define I2S_SCK 26  // BCLK pin

#ifndef _BV
#define _BV(bit) (1 << (bit))
#endif


// You can have up to 4 on one i2c bus but one is enough for testing!
Adafruit_MPR121 cap = Adafruit_MPR121();


// Keeps track of the last pins touched
// so we know when buttons are 'released'
uint16_t lasttouched = 0;
uint16_t currtouched = 0;

size_t bytes_written;
  const int sample_count = 1000;
  int16_t samples[sample_count];


void setup() {
  pinMode(27, OUTPUT) ;
  Serial.begin(9600);


  while (!Serial) { // needed to keep leonardo/micro from starting too fast!
    delay(10);
  }
 
  Serial.println("Adafruit MPR121 Capacitive Touch sensor test");
 
  // Default address is 0x5A, if tied to 3.3V its 0x5B
  // If tied to SDA its 0x5C and if SCL then 0x5D
  if (!cap.begin(0x5A)) {
    Serial.println("MPR121 not found, check wiring?");
    while (1);
  }
  Serial.println("MPR121 found!");

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



void playDoTone(){
  float frequency = 440.0;
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

void loop() {
  // Get the currently touched pads
  currtouched = cap.touched();


  

  for (uint8_t i=0; i<12; i++) {
    // it if is touched and wasnt touched before, alert!
    if ((currtouched & _BV(i)) && !(lasttouched & _BV(i)) ) {
      Serial.print(i); Serial.println(" touched");
      if (i==2) {digitalWrite(27,HIGH);
      playDoTone();
           
      }
    }
    // if it was touched and now isnt, alert!
    if (!(currtouched & _BV(i)) && (lasttouched & _BV(i)) ) {
      Serial.print(i); Serial.println(" released");
       if (i==2) {digitalWrite(27,LOW);
       stopTone();
       }
    }
  }

  i2s_write(I2S_NUM_0, samples, sizeof(samples), &bytes_written, portMAX_DELAY);


  // reset our state
  lasttouched = currtouched;


  // comment out this line for detailed data from the sensor!
  return;
 
  // debugging info, what
  Serial.print("\t\t\t\t\t\t\t\t\t\t\t\t\t 0x"); Serial.println(cap.touched(), HEX);
  Serial.print("Filt: ");
  for (uint8_t i=0; i<12; i++) {
    Serial.print(cap.filteredData(i)); Serial.print("\t");
  }
  Serial.println();
  Serial.print("Base: ");
  for (uint8_t i=0; i<12; i++) {
    Serial.print(cap.baselineData(i)); Serial.print("\t");
  }
  Serial.println();
 
  // put a delay so it isn't overwhelming
  delay(100);
}