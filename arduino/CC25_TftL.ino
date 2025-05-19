#include <Adafruit_NeoPixel.h>
#include "palette.h"

// Size of palette
#define PAL_SIZE 100
#define PAL_COUNT 4

// Number of LEDs in the strip
#define LED_COUNT 120

// How bright to make the strips (out of 255) initially
#define INIT_BRIGHTNESS 200

// How bright to make thes strips after a delay (for debugging/testing)
#define PROD_BRIGHTNESS 200

// Fixed point fraction size (1/100th) of each palette step
#define FP_SIZE 100

// Area which to add fuel to
#define FUEL_RANGE LED_COUNT/2

// Initial fuel when a the heart is beating
#define FUEL_INIT_ON_BEAT PAL_SIZE * FP_SIZE - 1
#define FUEL_INIT_NO_BEAT PAL_SIZE / 2 * FP_SIZE - 1

// How long a beat lasts
#define BEAT_DURATION_MIN 50
#define BEAT_DURATION_MAX 250

// How long to wait before the next beat
#define BEAT_DELAY_MIN 500
#define BEAT_DELAY_MAX 1500

// How long to rerandomize the beat timings
#define RESET_MIN_TIME 15000
#define RESET_MAX_TIME 60000

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

#define LED_PIN 1
Adafruit_NeoPixel strip = Adafruit_NeoPixel(LED_COUNT, LED_PIN, NEO_GRB + NEO_KHZ800);
int fire[LED_COUNT];
int is_bright;
int beat_duration;
int beat_delay;
int beat_multiplier;
long beat_trigger_time;
long reset_time;
int reset_delay;
int on_beat;
int beat_edge;
int pal_ofs = 0;
int routine = 0;
int flash_beat_fuel;
int glitch_sections;
int glitch_decay;

void setup() {
    strip.begin();           // INITIALIZE NeoPixel strip object (REQUIRED)
    strip.show();            // Turn OFF all pixels ASAP

    strip.setBrightness(INIT_BRIGHTNESS); // Set BRIGHTNESS to about 1/5 (max = 255)
    is_bright = 0;

    reset();
}

void reset() {
    reset_time = millis();
    reset_delay = int(random(RESET_MIN_TIME, RESET_MAX_TIME));

    reset_routine();

    if (routine == 0)
        reset_fire();
    else if (routine == 1)
        reset_flash();
    else if (routine == 2)
        reset_glitch();
    
    reset_leds();
    reset_beat();
    reset_palette();
}

void reset_palette() {
    pal_ofs = int(random(PAL_COUNT)) * PAL_SIZE * 3;
}

void reset_beat() {
    beat_duration = int(random(BEAT_DURATION_MIN, BEAT_DURATION_MAX)) * beat_multiplier;
    beat_delay = int(random(BEAT_DELAY_MIN, BEAT_DELAY_MAX)) * beat_multiplier;
    beat_trigger_time = millis();
    on_beat = 0;
    beat_edge = 1;
}

void reset_leds() {
    for (int i=0; i<LED_COUNT; i++) {
        strip.setPixelColor(i, 0, 0, 0);
    }
}

void reset_fire() {
    beat_multiplier = 5;

    for (int i=0; i<LED_COUNT; i++) {
        fire[i] = 0;
    }

    fire[0] = FUEL_INIT_NO_BEAT;
}

void reset_flash() {
    beat_multiplier = 1;
    flash_beat_fuel = int(random(PAL_SIZE/2*FP_SIZE, PAL_SIZE*FP_SIZE-1));
}

void reset_glitch() {
    beat_multiplier = 4;
    glitch_sections = int(random(2, 4));
    glitch_decay = int(random(DECAY_MIN, DECAY_MAX)/2);
    // Reuse the fire array to store the glitch sections
    for (int i=0; i<glitch_sections; i++) {
        fire[i] = 0;
    }
}

void reset_routine() {
    routine = int(random(0, 3));
}

void loop_fire() {
    int idx;

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
        fire[i] = min(fire[i], PAL_SIZE*FP_SIZE-1);
    }

    // Convert to palette
    for (int i=0; i<LED_COUNT; i++) {
        idx = fire[i] / FP_SIZE * 3 + pal_ofs;    
        strip.setPixelColor((LED_COUNT-1)-i, palette[idx], palette[idx+1], palette[idx+2]);
    }
}

void loop_flash() {
    long ms = millis();
    int fuel = on_beat % 2 == 0 ? FUEL_INIT_NO_BEAT : flash_beat_fuel;
    int decay = int(ms-beat_trigger_time) * (4-on_beat);
    fuel = max(0, fuel - decay);

    int idx = fuel / FP_SIZE * 3 + pal_ofs;
    for (int i=0; i<LED_COUNT; i++) {
        strip.setPixelColor(i, palette[idx], palette[idx+1], palette[idx+2]);
    }
}

void loop_glitch() {
    // In this routine we're going to reuse the fire array to represent each
    // section.  We'll only use the first 4 values of the array at most.

    // When we're on a beat_edge...
    if (beat_edge == 1) {
        // Randomly pick a secction to glitch
        int section = int(random(glitch_sections));

        // Use the fire array to store the new glitched section
        fire[section] = int(random((PAL_SIZE-PAL_SIZE/4)*FP_SIZE, PAL_SIZE*FP_SIZE-1));
    }
    
    int glitch_section_size = LED_COUNT / glitch_sections;
    // Decay all the sections in the fire array
    for (int i=0; i<glitch_sections; i++) {
        int decay = glitch_decay;
        fire[i] = max(0, fire[i] - decay);

        // Convert to palette and write to strip
        for (int j=0; j<glitch_section_size; j++) {
            int idx = fire[i] / FP_SIZE * 3 + pal_ofs;
            strip.setPixelColor(i*glitch_section_size+j, palette[idx], palette[idx+1], palette[idx+2]);
        }
    }
}

void loop() {
    long ms = millis();

    // Check if we need to change the beat state
    // When on_beat is zero we're in the long delay between beats
    // When it is one or three we're on a beat
    // When it is two we're in the short delay between thumps
    beat_edge = 0;
    int delay_time = on_beat == 0 ? beat_delay : beat_duration;
    if (ms > beat_trigger_time + delay_time) {
        on_beat = (on_beat + 1) % 4;
        beat_edge = 1;
        beat_trigger_time = ms;
    }

    if (routine == 0)
        loop_fire();
    else if (routine == 1) 
        loop_flash();
    else if (routine == 2)
        loop_glitch();

    strip.show();

    delay(10);

    // Change to production level of brightness if we're using test brightness
    if (is_bright == 0 && ms > 60000) {
        is_bright = 1;
        strip.setBrightness(PROD_BRIGHTNESS);
    }

    // Rerandomize the beat timings every once in awhile
    if (ms > reset_time + reset_delay) {
        reset();
    }
}



