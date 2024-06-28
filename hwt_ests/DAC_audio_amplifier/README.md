required hardware:
a speaker (connected to an amplifier).
an esp32 board.
wires.

steps:
connect to following pins in the amplifier:
VIN: Connect to the 3.3V or 5V pin on the ESP32 (depending on your amplifier's voltage requirements, typically 5V).
GND: Connect to a GND pin on the ESP32.
GAIN: If your amplifier has a gain pin, you can leave it unconnected or follow the amplifier’s datasheet for connection options (sometimes it can be connected to GND or VCC to set different gain levels).
DIN (Data In): Connect to the ESP32 I2S data output pin (usually GPIO 22 or GPIO 23).
BCLK (Bit Clock): Connect to the ESP32 I2S bit clock pin (usually GPIO 26).
LRC (Left/Right Clock): Connect to the ESP32 I2S left/right clock pin (usually GPIO 25).

connect the board to a power source, upload the sketch and enjoy.
