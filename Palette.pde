public class Palette {
    public int steps;
    public color[] colors;

    public Palette(int steps) {
        this.steps = steps;
        this.colors = new color[steps];
    }

    public void generateByHue(int baseHue) {
        colorMode(HSB, 360, 100, 100); // Ensure HSB mode is set

        for (int i = 0; i < this.steps; i++) {
            float s = pow(
                constrain(this.steps - i, 0, this.steps/4) / 
                (this.steps/4.0), 2
            ) * 100;

            float b = pow(
                constrain(i, 0, this.steps/2) / 
                (this.steps/2.0), 2
            ) * 100;

            this.colors[i] = color(
                baseHue, 
                constrain(s, 0, 100), 
                constrain(b, 0, 100)
            );
        }
        colorMode(RGB, 255); // Reset to RGB mode
    }

    public void addColorStop(color startColor, color endColor, int startIndex, int endIndex) {
        if (startIndex < 0 || endIndex >= this.steps || startIndex >= endIndex) {
            throw new IllegalArgumentException("Invalid color stop indices");
        }

        for (int i = startIndex; i <= endIndex; i++) {
            float ratio = (float)(i - startIndex) / (endIndex - startIndex);
            this.colors[i] = lerpColor(startColor, endColor, ratio);
        }
    }

    public void draw() {
        for (int i = 0; i < this.steps; i++) {
            fill(this.colors[i]);
            stroke(this.colors[i]);
            rect(i * width / this.steps, 0, 
                 width / this.steps, height);
        }
    }

    public int[] toArray() {
        int[] arr = new int[this.steps * 3];
        for (int i = 0; i < this.steps; i++) {
            arr[i * 3] = round(red(this.colors[i]));
            arr[i * 3 + 1] = round(green(this.colors[i]));
            arr[i * 3 + 2] = round(blue(this.colors[i]));
        }
        return arr;
    }

    public String toCString() {
        colorMode(RGB, 255); // Ensure RGB mode for export
        StringBuilder sb = new StringBuilder();
        sb.append("uint8_t palette[] = {\n");
        for (int i = 0; i < this.steps; i++) {
            sb.append("  ");
            sb.append(round(red(this.colors[i])));
            sb.append(",");
            sb.append(round(green(this.colors[i])));
            sb.append(",");
            sb.append(round(blue(this.colors[i])));

            if (i < this.steps - 1) {
                sb.append(",");
            }
            sb.append("\n");
        }
        sb.append("};\n");

        return sb.toString();
    }

    public void writeHeaderCode(String filename) {
        String content = this.toCString();
        saveStrings(filename, split(content, "\n"));
    }

}