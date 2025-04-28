# Transmissions from the Lost Simulator

This simulator is for Sophi Kravitz' project for Country Club 2025.  In this project 5 large white latex balloons will stand on rigid poles, inside each will be an LED strip, a microcontroller, and some other electronics.  The middle balloon will be connected to a heart rate monitor via radio and will allow participants to see their heart rate on the LEDs inside the balloon.  The other four will show a non-interactive pattern.

## Simulation and use on Arduino

The code in `Arduino.pde` is Processing code but written to be compatible Arduino C code.  This code *should* just compile and work within the Arduino environment.  The data that would've been written to an LED strip using the Adafruit library is instead displayed within the simulator.

## Export of Arduino code

When run the C code will be copied out of the `Arudino.pde` sketch, along with the constants in the main `CC25_TftL.pde` sketch and added to `arduino/CC25_TftL.ino`.  Additionally the palettes used are written to header files in the `arduino/` directory.

