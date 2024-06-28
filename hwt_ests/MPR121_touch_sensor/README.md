## required hardware:
MPR121 touch sensor.
ESP32 board.
wires.


## steps:
connect to following pins in the touch sensor:
VCC: Connect to 3.3V on the ESP32.
GND: Connect to GND on the ESP32.
SDA: Connect to GPIO 21 (I2C data line) on the ESP32.
SCL: Connect to GPIO 22 (I2C clock line) on the ESP32.
IRQ: Not necessary for basic functionality but can be connected to an interrupt pin on the ESP32 if needed for advanced features.

connect the board to a power source, upload the sketch, open your serial monitor and touch any electrodes of your choosing, the MPR121 has 12 electrodes so if you touch electrodes 5 for example the sentence “Touch detected on electrode: 5“ should appear on the screen.
