class Balloon {
  public float size;
  public float x;
  public float y;
  public Palette palette;
  public Arduino arduino;

  public Balloon(float x, float y, int size, Palette palette) {
      this.x = x;
      this.y = y;
      this.size = size;
      this.palette = palette;
    }

    public void setup() {
      this.arduino = new Arduino(palette.toArray());
      this.arduino.setup();
    }

    // Animate the colors array
    public void animate() {
      //this.arduino.loop();

      // int centerIdx = this.colors.length / 2;
      // this.colors[centerIdx] = getColorForStep(this.steps[0]);
      // for (int i=this.steps.length-1; i>0; i--) {
      //   this.steps[i] = max(this.steps[i-1] - 1, 0);
      //   this.colors[centerIdx+i] = this.colors[centerIdx-i] = getColorForStep(this.steps[i]);
      // }
      // this.steps[0] = max(this.steps[0] - int(random(0, 5)), 0);
    }

    // Draw the balloon circle using lines
    public void draw() {
      float r = this.size / 2;

      this.arduino.loop();
      color[] colors = this.arduino.getPixels();

      float colorIndex = 0;
      float colorStep = colors.length / this.size;
    

      for (float y = this.y - r; y <= this.y + r; y += 1) {
        float dy = y - this.y;

        // Check if we're within the circle
        if (dy * dy <= r * r) {
          float dx = sqrt(r * r - dy * dy);

          float x1 = this.x - dx;
          float x2 = this.x + dx;

          // Use the corresponding color for each line
          if (colorIndex < colors.length) {
            stroke(colors[int(colorIndex)]);
            line(x1, y, x2, y);
            colorIndex += colorStep;
          }
        }
      }
    }
}
