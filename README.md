# Thumby

Thumby is a small native macOS thumbnail editor for fast text-overlay iteration.

## Run

```bash
swift run
```

## Build A macOS App Bundle

```bash
./Scripts/package-app.sh
open .build/release/Thumby.app
```

## Current Workflow

1. Drop an image into the window, or choose one from disk.
2. Enter a short phrase or word.
3. Switch between `Minimal`, `Catchy`, and `Modern` profiles.
4. Adjust uppercase, size, text box width, text color, and picture outline.
5. Drag the text directly on the image preview.
6. Export a new PNG.

Text placement is stored relative to the image, so the exported PNG matches the preview placement at the original image resolution.
The picture outline matches the text color by default, but can be unlocked and changed independently.
