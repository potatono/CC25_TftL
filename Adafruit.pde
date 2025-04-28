class Adafruit_NeoPixel {
    color[] pixels;
    float brightness = 1.0;

    public Adafruit_NeoPixel(int numPixels) {
        this.pixels = new color[numPixels];
    }

    void begin() {
        for (int i = 0; i < pixels.length; i++) {
            pixels[i] = color(0, 0, 0); // Initialize all pixels to black
        }
    }
    void show() {

    }
    void setBrightness(int brightness) {
        this.brightness = constrain(brightness, 0, 255) / 255.0;
    }
    
    void setPixelColor(int index, int r, int g, int b) {
        if (index >= 0 && index < pixels.length) {
            pixels[index] = color(
                r * this.brightness,
                g * this.brightness,
                b * this.brightness
            );
        }
    }
}