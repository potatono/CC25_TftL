public class ArduinoWriter {
    String codePath = "../Arduino.pde";
    String constantsPath = "../Constants.pde";

    public ArduinoWriter(String constantsPath, String codePath) {
        this.constantsPath = constantsPath;
        this.codePath = codePath;
    }

    public String readArduinoCode() {
        String lines[] = loadStrings(this.codePath);
        boolean isCopying = false;

        StringBuilder sb = new StringBuilder();
        for (String line : lines) {
            if (line.startsWith("/** COPY")) {
                isCopying = true;
            }
            else if (line.startsWith("/** NOCOPY") || line.startsWith("**/")) {
                sb.append("\n");
                isCopying = false;
            }
            else if (isCopying) {
                // Strip leading 4 spaces
                if (line.startsWith("    ")) {
                    line = line.substring(4);
                }
                sb.append(line).append("\n");
            }
            else if (line.startsWith("/** CONSTANTS")) {
                sb.append(readConstants());
            }   
        }
        sb.append("\n");
        return sb.toString();
    }

    public String readConstants() {
        String lines[] = loadStrings(this.constantsPath);
        StringBuilder sb = new StringBuilder();
        boolean isCopying = false;

        for (String line : lines) {
            if (line.startsWith("/** COPY")) {
                isCopying = true;
            }
            else if (line.startsWith("/** NOCOPY")) {
                isCopying = false;
            }
            else if (isCopying) {
                // Strip all leading spaces
                line = line.trim();
                // Change static definition to #define
                line = line.replaceAll("^\\s*public static .*?\\s+([A-Z_]+)\\s*=\\s*", "#define $1 ");
                // Remove trailing semicolon
                line = line.replaceAll("\\s*;.*$", "");

                sb.append(line).append("\n");
            }
        }

        return sb.toString();
    }

    public void writeArduinoCode(String path) {
        String code = readArduinoCode();
        saveStrings(path, new String[] { code });
    }

    // public String getInoConstants() {
    //     // TODO Make this read from the main pde or use introspection
    //     StringBuilder sb = new StringBuilder();
    //     sb.append("#define LED_COUNT ").append(LED_COUNT).append("\n");
    //     sb.append("#define PAL_COUNT ").append(PAL_COUNT).append("\n");
    //     sb.append("#define INIT_BRIGHTNESS ").append(INIT_BRIGHTNESS).append("\n");
    //     sb.append("#define PROD_BRIGHTNESS ").append(PROD_BRIGHTNESS).append("\n");
    //     sb.append("#define FP_SIZE ").append(FP_SIZE).append("\n");
    //     sb.append("#define FUEL_RANGE ").append(FUEL_RANGE).append("\n");
    //     sb.append("#define FUEL_INIT_ON_BEAT ").append(FUEL_INIT_ON_BEAT).append("\n");
    //     sb.append("#define FUEL_INIT_NO_BEAT ").append(FUEL_INIT_NO_BEAT).append("\n");
    //     sb.append("#define BEAT_DURATION_MIN ").append(BEAT_DURATION_MIN).append("\n");
    //     sb.append("#define BEAT_DURATION_MAX ").append(BEAT_DURATION_MAX).append("\n");
    //     sb.append("#define BEAT_DELAY_MIN ").append(BEAT_DELAY_MIN).append("\n");
    //     sb.append("#define BEAT_DELAY_MAX ").append(BEAT_DELAY_MAX).append("\n");
    //     sb.append("#define BEAT_RESET_MIN_TIME ").append(BEAT_RESET_MIN_TIME).append("\n");
    //     sb.append("#define BEAT_RESET_MAX_TIME ").append(BEAT_RESET_MAX_TIME).append("\n");
    //     sb.append("#define FUEL_CHANCE ").append(FUEL_CHANCE).append("\n");
    //     sb.append("#define FUEL_MIN ").append(FUEL_MIN).append("\n");
    //     sb.append("#define FUEL_MAX ").append(FUEL_MAX).append("\n");
    //     sb.append("#define DECAY_CHANCE ").append(DECAY_CHANCE).append("\n");
    //     sb.append("#define DECAY_MIN ").append(DECAY_MIN).append("\n");
    //     sb.append("#define DECAY_MAX ").append(DECAY_MAX);
    //     return sb.toString();
    // }

    // public void exportInoToFile(String filename) {
    //     String code = getInoCode();
    //     saveStrings(filename, new String[] { code });
    // }

}