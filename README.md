# Thumby

A small, native macOS app for fast thumbnail text overlays. Drop in an image, type a word, pick a style, place it, export a PNG. No layers, no canvas setup.

> Read the story behind it in [ARTICLE.md](ARTICLE.md).

## Requirements

- macOS 14 or later
- Swift 6 toolchain (Xcode 16+ or the matching Swift toolchain) — only to build

## Run

```bash
swift run
```

## Build a macOS app bundle

```bash
./Scripts/package-app.sh
open .build/release/Thumby.app
```

## Usage

1. **Add an image** — drag a file onto the window, paste with `⌘V`, or pick one from disk. The image becomes the canvas.
2. **Type your text** — the phrase you want on the thumbnail.
3. **Pick a profile** — `Minimal`, `Catchy`, or `Modern` (preset font, size, and color).
4. **Tune it** — uppercase, text size, outline width, text-box width, and color. Optionally add a picture outline (frame) and a draggable attention arrow.
5. **Add layers (optional)** — paste or drop extra images (logos, product shots) and drag them into place.
6. **Position** — drag the text, arrow, or any layer directly over the preview.
7. **Export** — saves a PNG at the original image resolution. Placement is stored relative to the image, so the export matches the preview.
