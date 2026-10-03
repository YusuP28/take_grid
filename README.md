# Take Grid

Aplikasi Flutter untuk membuat kolase foto grid dengan kontrol penuh —
template, filter, overlay, dan free-style canvas.

## Fitur

### Grid Template
- Auto Grid: pilih 1-20 foto → langsung masuk editor
- **Varian layout cerdas** per jumlah foto (6-11 varian):
  - Uniform, Big Center, Big Top/Bottom/Left
  - Mosaic, Golden Ratio, Corner, Diagonal
  - Polaroid, Panorama, Strip
- Ganti layout kapan aja via tombol **Template** di editor
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
- **v1.1.0** — current (lihat CHANGELOG.md)

## Known Issues
- (kosong — semua fixed di v1.1.0)

## Lisensi
Private project.
