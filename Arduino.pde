public class Arduino {
    Adafruit_NeoPixel strip;
    int[] palette;
    int[] fire = new int[LED_COUNT];
    int beat_duration;
    int beat_delay;
    long beat_trigger_time;
    long beat_reset_time;
    int beat_reset_delay;
    int is_bright;
    int on_beat;

    public Arduino(int[] palette) {
        this.strip = new Adafruit_NeoPixel(LED_COUNT);
        this.palette = palette;
    }

    color[] getPixels() {
        return this.strip.pixels;
    }

    void delay(int ms) {}

    
/** COPY
    #include <Adafruit_NeoPixel.h>
    #include "palette.h"
**/

/** CONSTANTS
**/

/** COPY
    Adafruit_NeoPixel strip = Adafruit_NeoPixel(LED_COUNT, 6, NEO_GRB + NEO_KHZ800);
    int fire[LED_COUNT];
    int is_bright;
    int beat_duration;
    int beat_delay;
    long beat_trigger_time;
    long beat_reset_time;
    int beat_reset_delay;
    int on_beat;
**/

/** COPY **/
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
/** NOCOPY **/
}