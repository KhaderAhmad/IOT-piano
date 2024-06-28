# Concept:
this code connects a touvh sensor to a LED, when electrode 2 in the MPR121 touch sensor is touched the LED lights up (for as long as the eelctrode is touched).


## required hardware:
1. LED
2. resistor
3. ESP32 board
4. MPR121 touch sensor
5. wires

## steps:
### MPR121 pins:
1. 3.3v to 3v3
2. GND to GND
3. SCL to pin 22
4. SDA to pin 21

### LED pins:
1. the long leg to a resistor's leg
2. the resistor's second leg to pin 27
3. the short leg to GND (there are 2 gnds)


connect you board to the computer and run the sketch.
