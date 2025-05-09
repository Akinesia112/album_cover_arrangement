// Heart-shaped random multi-size album cover layout (20 pieces, 2~5px spacing, strictly within the heart shape)

import java.io.File;
import java.util.ArrayList;
import java.util.Collections;

// User adjustable parameters
final String ALBUM_DIR = "Your Album Covers Images"; // album cover dataset folder
int[] sizeOptions = {100, 80, 50,30};  // album cover size from large to small
int sampleN = 30;      // Number of target placements
float gapMin = 0.085;      // Minimum spacing
float gapMax = 0.095;      // Maximum spacing

ArrayList<PImage> albums;
ArrayList<Cell> cells;
PGraphics maskImg;

void setup() {
  size(800, 800);
  loadAlbums();   // 1) Loading cover images
  buildMask();    // 2) Constructing the heart shape mask
  defineCells();  // 3) Placing Cell
  assignImages(); // 4) Assign cover images
  noLoop();
}

void draw() {
  background(#FFD1DC);
  // Draw the heart outline
  stroke(255, 0, 127);
  strokeWeight(2);
  noFill();
  beginShape();
    int steps = 8000;
    for (int i = 0; i < steps; i++) {
      float t = map(i, 0, steps, 0, TWO_PI);
      float x = 16 * pow(sin(t), 3);
      float y = -(13*cos(t) - 5*cos(2*t) - 2*cos(3*t) - cos(4*t));
      vertex(width/2 + x*16, height/2 + y*16);
    }
  endShape(CLOSE);
  // draw cover
  noStroke();
  for (Cell c : cells) {
    if (c.img != null) {
      image(c.img, c.x - c.s/2, c.y - c.s/2, c.s, c.s);
    }
  }
}

// 1) load images
void loadAlbums() {
  albums = new ArrayList<PImage>();
  File folder = new File(ALBUM_DIR);
  if (!folder.exists() || !folder.isDirectory()) {
    println("Warning: ALBUM_DIR not found, using sketch/data");
    folder = new File(dataPath(""));
  }
  File[] files = folder.listFiles();
  if (files == null) exit();
  for (File f : files) {
    String name = f.getName().toLowerCase();
    if (name.endsWith(".jpg") || name.endsWith(".png")) {
      PImage img = loadImage(f.getAbsolutePath());
      if (img != null) albums.add(img);
    }
  }
  if (albums.isEmpty()) exit();
  println("Loaded " + albums.size() + " images.");
}

// 2) heart contour
void buildMask() {
  maskImg = createGraphics(width, height);
  maskImg.beginDraw();
  maskImg.background(0);
  maskImg.fill(255);
  maskImg.noStroke();
  maskImg.beginShape();
  int steps = 300;
  for (int i = 0; i < steps; i++) {
    float t = map(i, 0, steps, 0, TWO_PI);
    float x = 16 * pow(sin(t), 3);
    float y = -(13*cos(t) - 5*cos(2*t) - 2*cos(3*t) - cos(4*t));
    maskImg.vertex(width/2 + x*16, height/2 + y*16);
  }
  maskImg.endShape(CLOSE);
  maskImg.endDraw();
}

// 3) Randomly and dynamically place sampleN cells, 
// resize them according to the nearest neighbor, 
// and ensure that they are non-overlapping and within the heart shape.
void defineCells() {
  cells = new ArrayList<Cell>();
  int maxConsecutiveFails = 10000000;  // Maximum number of consecutive failures per size

  for (int s : sizeOptions) {
    int failCount = 0;
    while (failCount < maxConsecutiveFails) {
      float rx = random(width), ry = random(height);
      // 1) The center must be within the heart shape
      if (maskImg.get(floor(rx), floor(ry)) != color(255)) {
        failCount++;
        continue;
      }
      // 2) A random gap
      float gap = random(gapMin, gapMax);

      // 3) Axial separation detection
      boolean overlap = false;
      float halfS = s / 2f;
      for (Cell o : cells) {
        float halfO = o.s / 2f;
        float dx = abs(rx - o.x);
        float dy = abs(ry - o.y);
        float thresh = halfS + halfO + gap;
        // If they are not separated on both the X and Y axes, they are overlapping.
        if (dx < thresh && dy < thresh) {
          overlap = true;
          break;
        }
      }
      if (overlap) {
        failCount++;
        continue;
      }
      // 4) The four corners must also be within the heart shape
      if (!isInsideMask(rx, ry, s)) {
        failCount++;
        continue;
      }

      // Placed successfully
      cells.add(new Cell(rx, ry, s));
      failCount = 0;
    }
  }
}

// Check if the center and four corners are within the heart shape
boolean isInsideMask(float x, float y, float s) {
  float h = s/2;
  float[][] pts = {{x, y}, {x-h, y-h}, {x+h, y-h}, {x-h, y+h}, {x+h, y+h}};
  for (float[] p : pts) {
    int ix = floor(p[0]);
    int iy = floor(p[1]);
    if (ix < 0 || iy < 0 || ix >= width || iy >= height) return false;
    if (maskImg.get(ix, iy) != color(255)) return false;
  }
  return true;
}

// 4) Randomly assign different covers
void assignImages() {
  Collections.shuffle(albums);
  int n = min(cells.size(), sampleN);
  for (int i = 0; i < n; i++) {
    cells.get(i).img = albums.get(i);
  }
}

// Cell class
class Cell {
  float x, y, s;
  PImage img;
  Cell(float x, float y, float s) {
    this.x = x;
    this.y = y;
    this.s = s;
    this.img = null;
  }
}
