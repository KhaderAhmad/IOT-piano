#include <Wire.h>
#include <Adafruit_MPR121.h>

// Create MPR121 object
Adafruit_MPR121 cap = Adafruit_MPR121();

// Touch threshold and release threshold
#define TOUCH_THRESHOLD 12
#define RELEASE_THRESHOLD 6

void setup() {
  // Initialize serial communication
  Serial.begin(115200);
  Serial.println("MPR121 touch sensor test");

  // Initialize MPR121 sensor
  if (!cap.begin(0x5A)) { // Default I2C address for MPR121
    Serial.println("MPR121 not found, check wiring?");
    while (1);
  }
  Serial.println("MPR121 found!");

  // Set touch and release thresholds
  cap.setThresholds(TOUCH_THRESHOLD, RELEASE_THRESHOLD);
}

void loop() {
  // Check touch status
  uint16_t touched = cap.touched();

  // Print touch status
  for (uint8_t i = 0; i < 12; i++) {
    if (touched & (1 << i)) {
      Serial.print("Touch detected on electrode: ");
      Serial.println(i);
    }
  }

  // Small delay to avoid overwhelming the serial output
  delay(100);
}
