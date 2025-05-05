// HeartLayoutOptimization.pde
// Processing: 專輯封面拼愛心多目標最佳化，隨機取樣 20 張專輯封面

import java.io.File;
import java.util.Collections;

ArrayList<PImage> albums;
ArrayList<Cell> heartCells;
int[] sizeOptions = { 100, 150, 200 };

// GA 參數
int popSize       = 80;
int generations   = 300;
float crossoverRate = 0.8;
float mutationRate  = 0.1;

// 目標權重
float wAlign = 1.0;
float wColor = 1.0;
float wScale = 1.0;

ArrayList<Individual> population;

void setup() {
  size(800, 800);
  loadAlbums();
  buildHeartCells();
  initPopulation();
  runGA();
  noLoop();
}

void draw() {
  // 結果由 runGA() 呼叫 drawIndividual()
}

// 載入並隨機取樣20張專輯封面
void loadAlbums() {
  albums = new ArrayList<PImage>();
  // 先從 data/albums 讀取，若不存在則退而求其次讀 data
  File albumsFolder = new File(dataPath("albums"));
  File folder = (albumsFolder.exists() && albumsFolder.isDirectory())
                ? albumsFolder
                : new File(dataPath(""));

  File[] files = folder.listFiles();
  if (files == null || files.length == 0) {
    println("Error: no image files found in " + folder.getAbsolutePath());
    exit();
  }
  // 先收集所有符合格式的檔名
  ArrayList<String> paths = new ArrayList<String>();
  for (File f : files) {
    String name = f.getName().toLowerCase();
    if (name.endsWith(".jpg") || name.endsWith(".png")) {
      String rel = (folder.equals(albumsFolder) ? "albums/" + f.getName() : f.getName());
      paths.add(rel);
    }
  }
  if (paths.isEmpty()) {
    println("Error: no valid album images in " + folder.getAbsolutePath());
    exit();
  }
  // 隨機打散並取前20張
  Collections.shuffle(paths);
  int sampleCount = min(20, paths.size());
  for (int i = 0; i < sampleCount; i++) {
    PImage img = loadImage(paths.get(i));
    if (img != null) albums.add(img);
    else println("Warning: failed to load " + paths.get(i));
  }
  println("Loaded " + albums.size() + " randomly sampled album images.");
}

// 建立心形格點
void buildHeartCells() {
  heartCells = new ArrayList<Cell>();
  float cx = width/2, cy = height/2;
  int steps = 28;
  for (int i = 0; i < steps; i++) {
    float t = map(i, 0, steps, 0, TWO_PI);
    float x = 16 * pow(sin(t), 3);
    float y = -(13 * cos(t) - 5 * cos(2*t) - 2 * cos(3*t) - cos(4*t));
    heartCells.add(new Cell(cx + x*20, cy + y*20));
  }
}

// GA 初始化
void initPopulation() {
  population = new ArrayList<Individual>();
  for (int i = 0; i < popSize; i++) population.add(new Individual());
}

// 遺傳演算法主流程
void runGA() {
  for (int gen = 0; gen < generations; gen++) {
    for (Individual ind : population) ind.evaluate();
    ArrayList<Individual> next = new ArrayList<Individual>();
    while (next.size() < popSize) {
      Individual a = tournament();
      Individual b = tournament();
      Individual[] kids = (random(1) < crossoverRate) ? a.crossover(b) : new Individual[]{a.copy(), b.copy()};
      kids[0].mutate(); kids[1].mutate();
      next.add(kids[0]); if (next.size() < popSize) next.add(kids[1]);
    }
    population = next;
  }
  // 找最優解並繪製
  Individual best = population.get(0);
  for (Individual ind : population) if (ind.totalFitness() < best.totalFitness()) best = ind;
  drawIndividual(best);
}

// 淘汰賽選擇
Individual tournament() {
  Individual a = population.get((int)random(popSize));
  Individual b = population.get((int)random(popSize));
  return (a.totalFitness() < b.totalFitness()) ? a : b;
}

// 繪製結果
void drawIndividual(Individual ind) {
  background(255);
  for (int i = 0; i < heartCells.size(); i++) {
    Cell c = heartCells.get(i);
    PImage img = albums.get(ind.albumIdx[i]);
    int sz = sizeOptions[ind.sizeChoice[i]];
    image(img, c.x - sz/2, c.y - sz/2, sz, sz);
  }
}

// 心形格點
class Cell { float x,y; Cell(float x, float y){this.x=x;this.y=y;} }

// 基因與適應度
class Individual {
  int[] albumIdx, sizeChoice;
  float fAlign, fColor, fScale;
  Individual(){
    int n = heartCells.size();
    albumIdx = new int[n]; sizeChoice = new int[n];
    for (int i = 0; i < n; i++){
      albumIdx[i] = (int)random(albums.size());
      sizeChoice[i] = (int)random(sizeOptions.length);
    }
  }
  Individual copy(){
    Individual c = new Individual();
    arrayCopy(albumIdx, c.albumIdx);
    arrayCopy(sizeChoice, c.sizeChoice);
    return c;
  }
  Individual[] crossover(Individual o){
    Individual c1 = copy(), c2 = o.copy();
    int pt = (int)random(albumIdx.length);
    for (int i = pt; i < albumIdx.length; i++){
      int t = c1.albumIdx[i]; c1.albumIdx[i] = c2.albumIdx[i]; c2.albumIdx[i] = t;
      t = c1.sizeChoice[i]; c1.sizeChoice[i] = c2.sizeChoice[i]; c2.sizeChoice[i] = t;
    }
    return new Individual[]{c1,c2};
  }
  void mutate(){
    for (int i = 0; i < albumIdx.length; i++){
      if (random(1)<mutationRate) albumIdx[i] = (int)random(albums.size());
      if (random(1)<mutationRate) sizeChoice[i] = (int)random(sizeOptions.length);
    }
  }
  void evaluate(){
    fAlign = fColor = fScale = 0;
    // TODO: 填入對齊、色彩、縮放誤差計算
  }
  float totalFitness(){ return wAlign*fAlign + wColor*fColor + wScale*fScale; }
}
