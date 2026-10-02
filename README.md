# Take Grid

Aplikasi Flutter untuk membuat kolase foto grid dengan kontrol penuh —
template, filter, overlay, dan free-style canvas.

## Fitur

### Grid Template
- 8 template: 2×2, 3×3, 2×1, 1×2, 3×1, 1×3, 2×2 Big Left, 3×3 Big Center
- Auto Grid: pilih 1-12 foto → smart layout otomatis
- Rasio: 11 pilihan (1:1, 4:5, 9:16, dll)

### Free Style Canvas
- Drag, rotate, zoom bebas
- Reset & hapus item
- Per-cell transform (zoom 1-3x, rotasi, flip H/V)

### Editing
- Border: 0-20px (step 0.5)
- Rounded corner: 0-30
- Background: solid, gradient, blur foto
- Filter per cell: brightness, contrast, saturation, warmth
- Overlay teks (warna, size, live preview)
- Overlay emoji (40 preset)

### Export
- Format: JPG / PNG
- Resolusi: 720p, 1080p, 1440p, 2048p, 4K
- Save ke galeri + Share

## Tech Stack
- Flutter 3.24.5 · Dart
- Provider (state management)
- CustomPainter (render grid)
- image_picker, media_store_plus, share_plus
- flutter_colorpicker, uuid

## Build
Semua build via **GitHub Actions**:
- Debug APK
- Release split APK (arm64, armeabi-v7a, x86_64)

## Rilis
- **v1.0.0+2** — current (lihat CHANGELOG.md)

## Known Issues
- Canvas masih sedikit bergeser saat panel overlay muncul (perbaikan in-progress)

## Lisensi
Private project.
