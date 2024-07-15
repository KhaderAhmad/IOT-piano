/***************************************************************************************************************************************************/
/*                                                    includes and defines                                                                         */
/***************************************************************************************************************************************************/
#include <WiFi.h>
#include <HTTPClient.h>
#include <Wire.h>
#include <Arduino.h>
#include <string.h>


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
  Serial.println("here");

  

  int num = firebaseReadSongNum();
  String song1 = firebaseReadSong(1);
  String song2 = firebaseReadSong(2);


  // comment out this line for detailed data from the sensor!
  return;
}
