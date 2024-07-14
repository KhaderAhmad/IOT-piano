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
#define _SSID "jamila"          // Your WiFi SSID
#define _PASSWORD "12345678"      // Your WiFi Password
#define REFERENCE_URL "https://iot-piano-default-rtdb.firebaseio.com/"  // Your Firebase project reference url
#define FIREBASE_AUTH "AIzaSyCILPdBn3AT2HuUhhkgxdpyTmBTfFJmqRM"


Firebase firebase(REFERENCE_URL);

void firebaseSetup()
{
  WiFi.mode(WIFI_STA);
  WiFi.disconnect();
  delay(1000);

  // Connect to WiFi
  WiFi.begin(_SSID, _PASSWORD);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print("-");
  }
  
}

int firebaseReadSongNum()
{
  int songNum =  firebase.getInt("/SongNum");
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


  int num = firebaseReadSongNum();
  


  // comment out this line for detailed data from the sensor!
  return;
}
