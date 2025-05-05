# album_cover_arrangement
## Heart-Shaped Album Cover Collage  

A Processing Java sketch that randomly arranges a set of album-cover images of varying sizes into a heart-shaped layout. 
Larger covers are placed first, then progressively smaller ones fill remaining gaps until the shape is densely packed.

![螢幕擷取畫面 2025-05-06 014730](https://github.com/user-attachments/assets/20870081-42d4-4e2d-b745-329d8734864c)


---

## Features

- **Multi-size placement**: Supports any number of cover sizes (e.g. 100, 80, 50, 30 px).
- **Hierarchical filling**: Places largest covers first, then smaller covers iteratively fill residual space.
- **Strict heart mask**: Ensures every cover (including its four corners) lies within a mathematically defined heart outline.
- **Non-overlapping**: Uses axis-aligned separation checks + configurable spacing to avoid overlap.
- **Configurable**: Easily adjust cover sizes, number of placements, canvas size, and spacing.

---

## Datasets

- **Album Covers Images** from Kaggle: 80k of 512x512 Album Covers Images
- https://www.kaggle.com/datasets/greg115/album-covers-images

---

## Prerequisites

- **Processing 3+** or **Processing 4+**  
- Java mode enabled  
- A local folder of `.jpg`/`.png` album-cover images

---

## Usage

1. Clone or download this repo.  
2. Set `ALBUM_DIR` to the path of your image folder.  
3. Adjust parameters in the top of the sketch:
   ```
   int[] sizeOptions = {100, 80, 50, 30};
   int sampleN       = 30;
   float gapMin      = 0.085;
   float gapMax      = 0.095;
   ```
