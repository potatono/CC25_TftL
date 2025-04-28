/** COPY **/
// Size of palette
public static int PAL_COUNT = 100;

// Number of LEDs in the strip
public static int LED_COUNT = 160;

// How bright to make the strips (out of 255) initially
public static int INIT_BRIGHTNESS=255; //50; 

// How bright to make thes strips after a delay (for debugging/testing)
public static int PROD_BRIGHTNESS=255; //200;

// Fixed point fraction size (1/100th) of each palette step
public static int FP_SIZE=100;

// Area which to add fuel to
public static int FUEL_RANGE=LED_COUNT/2;

// Initial fuel when a the heart is beating
public static int FUEL_INIT_ON_BEAT = PAL_COUNT * FP_SIZE - 1;
public static int FUEL_INIT_NO_BEAT = PAL_COUNT / 2 * FP_SIZE - 1;

// How long a beat lasts
public static int BEAT_DURATION_MIN = 50;
public static int BEAT_DURATION_MAX = 250;

// How long to wait before the next beat
public static int BEAT_DELAY_MIN = 500;
public static int BEAT_DELAY_MAX = 1500;

// How long to rerandomize the beat timings
public static int BEAT_RESET_MIN_TIME = 15000;
public static int BEAT_RESET_MAX_TIME = 60000;

// Chance of additional fuel
public static int FUEL_CHANCE=10;
public static int FUEL_MIN=FP_SIZE/2;
public static int FUEL_MAX=FP_SIZE;

// Chance a pixel will get extra decay
public static int DECAY_CHANCE=20;

// Minimum amount to decay
public static int DECAY_MIN=FP_SIZE/2;

// Maximum amount to decay
public static int DECAY_MAX=FP_SIZE*2;
/** NOCOPY **/

Balloon[] balloons;
PImage img;

void setup() {
  size(1280, 720);

  img = loadImage("background.jpg");
  frameRate(240);

  Palette reds = new Palette(PAL_COUNT);
  Palette greens = new Palette(PAL_COUNT);
  Palette pornj = new Palette(PAL_COUNT);
  Palette dress = new Palette(PAL_COUNT);

  reds.generateByHue(0);
  greens.generateByHue(120);
  pornj.addColorStop(color(0,0,0), color(255,0,177), 0, 24);
  pornj.addColorStop(color(255,0,177), color(255,177,0), 25, 74);
  pornj.addColorStop(color(255,177,0), color(255,255,255), 75, 99);

  dress.addColorStop(color(0,0,0), color(0, 0x66, 0xff), 0, 24);
  dress.addColorStop(color(0, 0x66, 0xff), color(0xff, 0xcc, 0), 25, 74);
  dress.addColorStop(color(0xff, 0xcc, 0), color(255,255,255), 75, 99);

  balloons = new Balloon[] {
    new Balloon(128, 480, 100, pornj),
    new Balloon(384, 480, 100, dress),
    new Balloon(640, 360, 100, greens),
    new Balloon(896, 480, 100, dress),
    new Balloon(1152, 480, 100, pornj),
  };

  for (Balloon balloon : balloons) {
    balloon.setup();
  }

  ArduinoWriter arduinoWriter = new ArduinoWriter("../CC25_TftL.pde", "../Arduino.pde");
  arduinoWriter.writeArduinoCode("arduino/CC25_TftL.ino");
  reds.writeHeaderCode("arduino/pal_red.h"); 
  greens.writeHeaderCode("arduino/pal_green.h");
  pornj.writeHeaderCode("arduino/pal_pornj.h");
  dress.writeHeaderCode("arduino/pal_dress.h");
  pornj.writeHeaderCode("arduino/palette.h");
}

void draw() {
  image(img, 0, 0);

  for (Balloon balloon : balloons) {
    balloon.animate();
    balloon.draw();
  }
}
