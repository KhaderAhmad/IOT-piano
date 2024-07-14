/***************************************************************************************************************************************************/
/*                                                    includes and defines                                                                         */
/***************************************************************************************************************************************************/
#include <WiFi.h>
#include <HTTPClient.h>
#include <Wire.h>
#include <Arduino.h>


/***************************************************************************************************************************************************/
/*                                                         WIFI CONNECTION                                                                         */
/***************************************************************************************************************************************************/
#include <ESP32Firebase.h>
//#include <Arduino.h>
//#include <Adafruit_NeoPixel.h>
#define _SSID "Adan:)"          // Your WiFi SSID
#define _PASSWORD "12345678"      // Your WiFi Password
#define REFERENCE_URL "https://console.firebase.google.com/u/0/project/iot-pianos24/settings/general"  // Your Firebase project reference url


Firebase firebase(REFERENCE_URL);

void firebaseSetup()
{
  WiFi.mode(WIFI_STA);
  WiFi.disconnect();
  delay(1000);

  // Connect to WiFi
  WiFi.begin(_SSID, _PASSWORD);

  // while (WiFi.status() != WL_CONNECTED) {
  //   delay(500);
  //   Serial.print("-");
  // }

}

int firebaseReadSongNum()
{
  int songNum =  firebase.getInt("songNum");
  Serial.print("SongNum is:");
  Serial.println(songNum);
  return songNum;
}

/***************************************************************************************************************************************************/
/*                                                              setup                                                                              */
/***************************************************************************************************************************************************/

void setup() {
  // pinMode(27, OUTPUT) ;
 Serial.begin(9600);


  while (!Serial) { // needed to keep leonardo/micro from starting too fast!
    delay(10);
  }
 

  firebaseSetup();
}


/***************************************************************************************************************************************************/
/*                                                                loop                                                                             */
/***************************************************************************************************************************************************/

void loop() {
  // // Get the currently touched pads
  // currtouched = cap.touched();

  // for (uint8_t i=0; i<12; i++) {
  //   // it if is touched and wasnt touched before, alert!
  //   if ((currtouched & _BV(i)) && !(lasttouched & _BV(i)) ) {
  //     Serial.print(i); Serial.println(" touched");
  //     playSoundByNum(i);
  //   }
  //   // if it was touched and now isnt, alert!
  //   if (!(currtouched & _BV(i)) && (lasttouched & _BV(i)) ) {
  //     Serial.print(i); Serial.println(" released");
  //      stopTone();
  //   }
  // }

  // i2s_write(I2S_NUM_0, samples, sizeof(samples), &bytes_written, portMAX_DELAY);


  // // reset our state
  // lasttouched = currtouched;

  int num = firebaseReadSongNum();
  Serial.print(num);
  


  // comment out this line for detailed data from the sensor!
  return;
}
