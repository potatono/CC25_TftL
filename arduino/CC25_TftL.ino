#include <Adafruit_NeoPixel.h>
#include "palette.h"

// Size of palette
#define PAL_COUNT 100

// Number of LEDs in the strip
#define LED_COUNT 160

// How bright to make the strips (out of 255) initially
#define INIT_BRIGHTNESS 255

// How bright to make thes strips after a delay (for debugging/testing)
#define PROD_BRIGHTNESS 255

// Fixed point fraction size (1/100th) of each palette step
#define FP_SIZE 100

// Area which to add fuel to
#define FUEL_RANGE LED_COUNT/2

// Initial fuel when a the heart is beating
#define FUEL_INIT_ON_BEAT PAL_COUNT * FP_SIZE - 1
#define FUEL_INIT_NO_BEAT PAL_COUNT / 2 * FP_SIZE - 1

// How long a beat lasts
#define BEAT_DURATION_MIN 50
#define BEAT_DURATION_MAX 250

// How long to wait before the next beat
#define BEAT_DELAY_MIN 500
#define BEAT_DELAY_MAX 1500

// How long to rerandomize the beat timings
#define BEAT_RESET_MIN_TIME 15000
#define BEAT_RESET_MAX_TIME 60000

// Chance of additional fuel
#define FUEL_CHANCE 10
#define FUEL_MIN FP_SIZE/2
#define FUEL_MAX FP_SIZE

// Chance a pixel will get extra decay
#define DECAY_CHANCE 20

// Minimum amount to decay
#define DECAY_MIN FP_SIZE/2

// Maximum amount to decay
#define DECAY_MAX FP_SIZE*2

Adafruit_NeoPixel strip = Adafruit_NeoPixel(LED_COUNT, 6, NEO_GRB + NEO_KHZ800);
int fire[LED_COUNT];
int is_bright;
int beat_duration;
int beat_delay;
long beat_trigger_time;
long beat_reset_time;
int beat_reset_delay;
int on_beat;

void setup() {
    strip.begin();           // INITIALIZE NeoPixel strip object (REQUIRED)
    strip.show();            // Turn OFF all pixels ASAP
    strip.setBrightness(INIT_BRIGHTNESS); // Set BRIGHTNESS to about 1/5 (max = 255)

    for (int i=0; i<LED_COUNT; i++) {
        fire[i] = 0;
    }

    fire[0] = FUEL_INIT_NO_BEAT;
    is_bright = 0;
    on_beat = 0;
    beat_duration = int(random(BEAT_DURATION_MIN, BEAT_DURATION_MAX));
    beat_delay = int(random(BEAT_DELAY_MIN, BEAT_DELAY_MAX));
    beat_trigger_time = millis();
    beat_reset_time = millis();
    beat_reset_delay = int(random(BEAT_RESET_MIN_TIME, BEAT_RESET_MAX_TIME));
}

void beat_reset() {
    beat_duration = int(random(BEAT_DURATION_MIN, BEAT_DURATION_MAX));
    beat_delay = int(random(BEAT_DELAY_MIN, BEAT_DELAY_MAX));
    beat_reset_delay = int(random(BEAT_RESET_MIN_TIME, BEAT_RESET_MAX_TIME));
    beat_reset_time = millis();
}

void loop() {
    long ms = millis();
    int idx;

    // Check if we need to change the beat state
    // When on_beat is zero we're in the long delay between beats
    // When it is one or three we're on a beat
    // When it is two we're in the short delay between thumps
    int delay_time = on_beat == 0 ? beat_delay : beat_duration;
    if (ms > beat_trigger_time + delay_time) {
        on_beat = (on_beat + 1) % 4;
        beat_trigger_time = ms;
    }
    
    // Initialize the fire based on the beat state
    fire[0] = on_beat % 2 == 0 ? FUEL_INIT_NO_BEAT : FUEL_INIT_ON_BEAT;

    // Randomly add more fuel to the bottom of the fire so it doesn't look so static
    for (int i=1; i<FUEL_RANGE; i++) {
        if (random(100) < FUEL_CHANCE) {
            fire[i] += random(FUEL_MIN, FUEL_MAX);
        }
    }

    // Burn from top down to bottom
    for (int i=LED_COUNT-2; i>0; i--) {
        // Average current pixel with next
        fire[i] = (fire[i] + fire[i-1])/2;

        // Randomly add extra decay
        if (random(100) < DECAY_CHANCE)
            fire[i]-= random(DECAY_MIN, DECAY_MAX);

        // Min/max cap
        fire[i] = max(0, fire[i]);
        fire[i] = min(fire[i], PAL_COUNT*FP_SIZE-1);
    }

    // Convert to palette
    for (int i=0; i<LED_COUNT; i++) {
        idx = fire[i] / FP_SIZE * 3;    
        strip.setPixelColor((LED_COUNT-1)-i, palette[idx], palette[idx+1], palette[idx+2]);
    }
    strip.show();

    delay(10);

    // Change to production level of brightness if we're using test brightness
    if (is_bright == 0 && ms > 60000) {
        is_bright = 1;
        strip.setBrightness(PROD_BRIGHTNESS);
    }

    // Rerandomize the beat timings every once in awhile
    if (ms > beat_reset_time + beat_reset_delay) {
        beat_reset();
    }
}



