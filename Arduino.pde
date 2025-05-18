public class Arduino {
    Adafruit_NeoPixel strip;
    int[] palette;
    int[] fire = new int[LED_COUNT];
    int beat_duration;
    int beat_delay;
    int beat_multiplier;
    long beat_trigger_time;
    long reset_time;
    int reset_delay;
    int is_bright;
    int on_beat;
    int pal_ofs = 0;
    int routine = 0;
    int flash_beat_fuel;

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
    int pal_ofs = 0;
    int routine = 0;
    int flash_beat_fuel;
**/

/** COPY **/
    void setup() {
        strip.begin();           // INITIALIZE NeoPixel strip object (REQUIRED)
        strip.show();            // Turn OFF all pixels ASAP

        strip.setBrightness(INIT_BRIGHTNESS); // Set BRIGHTNESS to about 1/5 (max = 255)
        is_bright = 0;

        reset();
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

    void reset() {
        reset_time = millis();
        reset_delay = int(random(RESET_MIN_TIME, RESET_MAX_TIME));

        reset_routine();

        if (routine == 0)
            reset_fire();
        else if (routine == 1)
            reset_flash();
        
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
    }

    void reset_routine() {
        routine = int(random(0, 2));
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

    void loop() {
        long ms = millis();

        // Check if we need to change the beat state
        // When on_beat is zero we're in the long delay between beats
        // When it is one or three we're on a beat
        // When it is two we're in the short delay between thumps
        int delay_time = on_beat == 0 ? beat_delay : beat_duration;
        if (ms > beat_trigger_time + delay_time) {
            on_beat = (on_beat + 1) % 4;
            beat_trigger_time = ms;
        }

        if (routine == 0)
            loop_fire();
        else if (routine == 1) 
            loop_flash();

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
/** NOCOPY **/
}
