# Changelog

## [1.2.0] - 2026-10-06

### Added
- Save Project — simpan grid sebagai draft di SQLite (ProjectService)
- Save As — simpan sebagai project baru dengan nama custom
- Auto thumbnail — preview project otomatis dari canvas
- Load project — buka draft dari home screen
- Drafts section di home — grid thumbnail 2 kolom
- Delete project — long-press card + konfirmasi
- GridProject serialisasi JSON (toJson/fromJson)
- GridTemplates.byId + byIdOrFirst helper

### Removed
- layout_picker_screen.dart (dead code, tidak dipakai)

### Changed
- HomeScreen: StatelessWidget → StatefulWidget (refresh draft list)
- EditorScreen: AppBar tombol Save + menu Simpan Sebagai

## [1.1.1] - 2026-10-04

### Added
- Drag foto dalam cell pakai jari (pan offset)
- Pinch-to-zoom foto dalam cell (skala 1-5x)

### Fixed
- Pan foto akumulatif — geser smooth ke segala arah
- Sebelumnya: foto cuma geser 1x kecil lalu diam


## [1.1.0] - 2026-10-03

### Added
- Auto Grid: max foto naik 12 → 20
- Auto Grid langsung masuk editor (skip screen perantara)
- Tombol Template di editor — ganti layout tanpa keluar
- Varian layout baru: Mosaic, Golden Ratio, Corner, Diagonal, Polaroid, Panorama, Strip
- 6-11 varian template per jumlah foto (2-9 foto)
- Tombol Rotasi di toolbar — akses cepat transform per cell
- Panel transform: zoom (1-3x), rotasi (-180° to 180°), flip H/V

### Fixed
- Tombol Template & Rotasi tidak double-highlight
- Canvas posisi di atas (konsisten sebelum/sesudah panel)
- Ganti template pertahankan border, sudut, warna, overlay, foto

### Removed
- LayoutPickerScreen (digantikan tombol Template di editor)


## [1.0.0+2] - 2026-10-02

### Added
- Fitur editor grid lengkap (8 template + auto grid)
- Free Style Canvas (drag, rotate, zoom, flip)
- Filter per cell (brightness, contrast, saturation, warmth)
- Overlay teks + emoji (40 preset)
- Export JPG/PNG (720p - 4K)
- Share + Save ke galeri
- Settings (auto-save, HD default)

### Fixed
- Panel overlay editor (canvas tetap diam saat panel muncul)
- Toolbar tidak tenggelam saat Filter/Emoji
- Filter auto-pilih cell

### Known Issues
- Canvas masih sedikit bergeser saat panel overlay muncul (perbaikan in-progress)

## [1.0.0] - 2026-09-30
- Initial release
