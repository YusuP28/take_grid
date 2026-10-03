import '../models/grid_template.dart';

/// Service generate template grid berdasarkan jumlah foto (1-20).
/// Setiap count punya beberapa varian jenis layout:
/// uniform, big-center, big-top, mosaic, golden, corner, diagonal, polaroid, panorama.
class SmartGridService {
  static GridTemplate forPhotoCount(int count) =>
      variantsFor(count).first;

  static List<GridTemplate> variantsFor(int count) {
    switch (count) {
      case 1:  return _v1();
      case 2:  return _v2();
      case 3:  return _v3();
      case 4:  return _v4();
      case 5:  return _v5();
      case 6:  return _v6();
      case 7:  return _v7();
      case 8:  return _v8();
      case 9:  return _v9();
      case 10: return _v10();
      case 11: return _v11();
      case 12: return _v12();
      case 13: return _v13();
      case 14: return _v14();
      case 15: return _v15();
      case 16: return _v16();
      case 17: return _v17();
      case 18: return _v18();
      case 19: return _v19();
      case 20: return _v20();
      default: return _v4();
    }
  }

  // ============ HELPERS ============
  static GridCell c(double x, double y, double w, double h) =>
      GridCell(x: x, y: y, w: w, h: h);

  static List<GridCell> _uniformGrid(int rows, int cols) {
    final cw = 1.0 / cols;
    final ch = 1.0 / rows;
    final cells = <GridCell>[];
    for (int r = 0; r < rows; r++) {
      for (int col = 0; col < cols; col++) {
        cells.add(c(col * cw, r * ch, cw, ch));
      }
    }
    return cells;
  }

  // Konstanta golden ratio
  static const double _g = 0.618;

  // ============ 1 FOTO ============
  static List<GridTemplate> _v1() => [
        GridTemplate(id: 'v1_full', name: '1 Foto', cols: 1, rows: 1,
            cells: [c(0, 0, 1, 1)]),
      ];

  // ============ 2 FOTO ============
  static List<GridTemplate> _v2() => [
        GridTemplate(id: 'v2_h', name: '2 Samping', cols: 2, rows: 1,
            cells: [c(0, 0, 0.5, 1), c(0.5, 0, 0.5, 1)]),
        GridTemplate(id: 'v2_v', name: '2 Tumpuk', cols: 1, rows: 2,
            cells: [c(0, 0, 1, 0.5), c(0, 0.5, 1, 0.5)]),
        GridTemplate(id: 'v2_bigL', name: 'Besar Kiri', cols: 2, rows: 1,
            cells: [c(0, 0, 0.65, 1), c(0.65, 0, 0.35, 1)]),
        GridTemplate(id: 'v2_bigR', name: 'Besar Kanan', cols: 2, rows: 1,
            cells: [c(0, 0, 0.35, 1), c(0.35, 0, 0.65, 1)]),
        GridTemplate(id: 'v2_goldenL', name: 'Golden Kiri', cols: 2, rows: 1,
            cells: [c(0, 0, _g, 1), c(_g, 0, 1 - _g, 1)]),
        GridTemplate(id: 'v2_goldenT', name: 'Golden Atas', cols: 1, rows: 2,
            cells: [c(0, 0, 1, _g), c(0, _g, 1, 1 - _g)]),
        GridTemplate(id: 'v2_diag', name: 'Diagonal', cols: 2, rows: 2,
            cells: [c(0, 0, 0.6, 0.6), c(0.4, 0.4, 0.6, 0.6)]),
        GridTemplate(id: 'v2_polaroid', name: 'Polaroid', cols: 3, rows: 3,
            cells: [c(0.15, 0.15, 0.7, 0.7), c(0, 0, 1, 0.12)]),
      ];

  // ============ 3 FOTO ============
  static List<GridTemplate> _v3() => [
        GridTemplate(id: 'v3_bigL', name: 'Besar Kiri', cols: 2, rows: 2,
            cells: [c(0, 0, 0.5, 1), c(0.5, 0, 0.5, 0.5), c(0.5, 0.5, 0.5, 0.5)]),
        GridTemplate(id: 'v3_bigR', name: 'Besar Kanan', cols: 2, rows: 2,
            cells: [c(0, 0, 0.5, 0.5), c(0, 0.5, 0.5, 0.5), c(0.5, 0, 0.5, 1)]),
        GridTemplate(id: 'v3_bigT', name: 'Besar Atas', cols: 2, rows: 2,
            cells: [c(0, 0, 1, 0.6), c(0, 0.6, 0.5, 0.4), c(0.5, 0.6, 0.5, 0.4)]),
        GridTemplate(id: 'v3_bigB', name: 'Besar Bawah', cols: 2, rows: 2,
            cells: [c(0, 0, 0.5, 0.4), c(0.5, 0, 0.5, 0.4), c(0, 0.4, 1, 0.6)]),
        GridTemplate(id: 'v3_row', name: '3 Sebaris', cols: 3, rows: 1,
            cells: _uniformGrid(1, 3)),
        GridTemplate(id: 'v3_col', name: '3 Setumpuk', cols: 1, rows: 3,
            cells: _uniformGrid(3, 1)),
        GridTemplate(id: 'v3_goldenL', name: 'Golden Kiri', cols: 2, rows: 2,
            cells: [c(0, 0, _g, 1), c(_g, 0, 1 - _g, 0.5), c(_g, 0.5, 1 - _g, 0.5)]),
        GridTemplate(id: 'v3_cornerTL', name: 'Pojok Kiri Atas', cols: 3, rows: 3,
            cells: [c(0, 0, 0.6, 0.6), c(0.6, 0, 0.4, 0.5), c(0, 0.6, 0.5, 0.4)]),
        GridTemplate(id: 'v3_diag', name: 'Diagonal', cols: 3, rows: 3,
            cells: [c(0, 0, 0.5, 0.5), c(0.25, 0.25, 0.5, 0.5), c(0.5, 0.5, 0.5, 0.5)]),
        GridTemplate(id: 'v3_mosaic', name: 'Mosaic', cols: 3, rows: 3,
            cells: [c(0, 0, 0.5, 0.5), c(0.5, 0, 0.5, 0.35), c(0.5, 0.35, 0.5, 0.65)]),
      ];

  // ============ 4 FOTO ============
  static List<GridTemplate> _v4() => [
        GridTemplate(id: 'v4_2x2', name: '2×2', cols: 2, rows: 2,
            cells: _uniformGrid(2, 2)),
        GridTemplate(id: 'v4_4x1', name: '4 Sebaris', cols: 4, rows: 1,
            cells: _uniformGrid(1, 4)),
        GridTemplate(id: 'v4_1x4', name: '4 Setumpuk', cols: 1, rows: 4,
            cells: _uniformGrid(4, 1)),
        GridTemplate(id: 'v4_bigT', name: 'Besar Atas', cols: 3, rows: 2,
            cells: [c(0, 0, 1, 0.55), c(0, 0.55, 0.333, 0.45),
                    c(0.333, 0.55, 0.334, 0.45), c(0.666, 0.55, 0.334, 0.45)]),
        GridTemplate(id: 'v4_bigB', name: 'Besar Bawah', cols: 3, rows: 2,
            cells: [c(0, 0, 0.333, 0.45), c(0.333, 0, 0.334, 0.45),
                    c(0.666, 0, 0.334, 0.45), c(0, 0.45, 1, 0.55)]),
        GridTemplate(id: 'v4_bigL', name: 'Besar Kiri', cols: 3, rows: 2,
            cells: [c(0, 0, 0.6, 1), c(0.6, 0, 0.4, 0.5), c(0.6, 0.5, 0.4, 0.25), c(0.6, 0.75, 0.4, 0.25)]),
        GridTemplate(id: 'v4_mosaic', name: 'Mosaic', cols: 3, rows: 3,
            cells: [c(0, 0, 0.6, 0.6), c(0.6, 0, 0.4, 0.4),
                    c(0.6, 0.4, 0.4, 0.6), c(0, 0.6, 0.6, 0.4)]),
        GridTemplate(id: 'v4_goldenT', name: 'Golden Atas', cols: 2, rows: 3,
            cells: [c(0, 0, 1, _g), c(0, _g, 0.5, 1 - _g),
                    c(0.5, _g, 0.5, (1 - _g) / 2), c(0.5, _g + (1 - _g) / 2, 0.5, (1 - _g) / 2)]),
        GridTemplate(id: 'v4_cornerTL', name: 'Pojok', cols: 3, rows: 3,
            cells: [c(0, 0, 0.6, 0.6), c(0.6, 0, 0.4, 0.3),
                    c(0.6, 0.3, 0.4, 0.3), c(0, 0.6, 0.6, 0.4)]),
        GridTemplate(id: 'v4_diag', name: 'Diagonal', cols: 3, rows: 3,
            cells: [c(0, 0, 0.5, 0.5), c(0.25, 0.25, 0.5, 0.5),
                    c(0.5, 0, 0.5, 0.5), c(0, 0.5, 0.5, 0.5)]),
        GridTemplate(id: 'v4_pano', name: 'Panorama', cols: 3, rows: 3,
            cells: [c(0, 0, 1, 0.4), c(0, 0.4, 0.333, 0.6),
                    c(0.333, 0.4, 0.334, 0.6), c(0.666, 0.4, 0.334, 0.6)]),
      ];

  // ============ 5 FOTO ============
  static List<GridTemplate> _v5() => [
        GridTemplate(id: 'v5_bigC', name: 'Besar Tengah', cols: 3, rows: 3,
            cells: [c(0, 0, 0.333, 0.5), c(0.333, 0, 0.334, 0.5), c(0.666, 0, 0.334, 0.5),
                    c(0, 0.5, 0.5, 0.5), c(0.5, 0.5, 0.5, 0.5)]),
        GridTemplate(id: 'v5_bigT', name: 'Besar Atas', cols: 2, rows: 3,
            cells: [c(0, 0, 1, 0.5), c(0, 0.5, 0.5, 0.25), c(0.5, 0.5, 0.5, 0.25),
                    c(0, 0.75, 0.5, 0.25), c(0.5, 0.75, 0.5, 0.25)]),
        GridTemplate(id: 'v5_bigL', name: 'Besar Kiri', cols: 3, rows: 2,
            cells: [c(0, 0, 0.5, 1), c(0.5, 0, 0.25, 0.5), c(0.75, 0, 0.25, 0.5),
                    c(0.5, 0.5, 0.25, 0.5), c(0.75, 0.5, 0.25, 0.5)]),
        GridTemplate(id: 'v5_mosaic', name: 'Mosaic', cols: 4, rows: 4,
            cells: [c(0, 0, 0.5, 0.5), c(0.5, 0, 0.5, 0.5),
                    c(0, 0.5, 0.25, 0.5), c(0.25, 0.5, 0.25, 0.5), c(0.5, 0.5, 0.5, 0.5)]),
        GridTemplate(id: 'v5_goldenL', name: 'Golden Kiri', cols: 3, rows: 3,
            cells: [c(0, 0, _g, 1), c(_g, 0, 1 - _g, 0.5),
                    c(_g, 0.5, (1 - _g) / 2, 0.5), c(_g + (1 - _g) / 2, 0.5, (1 - _g) / 2, 0.5),
                    c(_g, 0, 1 - _g, 0.25)]),
        GridTemplate(id: 'v5_corner', name: 'Pojok', cols: 3, rows: 3,
            cells: [c(0, 0, 0.6, 0.6), c(0.6, 0, 0.4, 0.3),
                    c(0.6, 0.3, 0.4, 0.3), c(0, 0.6, 0.6, 0.2), c(0, 0.8, 0.6, 0.2)]),
        GridTemplate(id: 'v5_pano', name: 'Panorama', cols: 3, rows: 3,
            cells: [c(0, 0, 1, 0.4), c(0, 0.4, 0.333, 0.3),
                    c(0.333, 0.4, 0.334, 0.3), c(0.666, 0.4, 0.334, 0.3),
                    c(0, 0.7, 1, 0.3)]),
        GridTemplate(id: 'v5_strip', name: 'Strip', cols: 3, rows: 3,
            cells: [c(0, 0, 0.6, 0.5), c(0.6, 0, 0.4, 0.25), c(0.6, 0.25, 0.4, 0.25),
                    c(0, 0.5, 0.333, 0.5), c(0.333, 0.5, 0.334, 0.5), c(0.666, 0.5, 0.334, 0.5)]),
      ];

  // ============ 6 FOTO ============
  static List<GridTemplate> _v6() => [
        GridTemplate(id: 'v6_3x2', name: '3×2', cols: 3, rows: 2,
            cells: _uniformGrid(2, 3)),
        GridTemplate(id: 'v6_2x3', name: '2×3', cols: 2, rows: 3,
            cells: _uniformGrid(3, 2)),
        GridTemplate(id: 'v6_6x1', name: '6 Sebaris', cols: 6, rows: 1,
            cells: _uniformGrid(1, 6)),
        GridTemplate(id: 'v6_bigT', name: 'Besar Atas', cols: 3, rows: 3,
            cells: [c(0, 0, 1, 0.5), c(0, 0.5, 0.333, 0.25), c(0.333, 0.5, 0.334, 0.25),
                    c(0.666, 0.5, 0.334, 0.25), c(0, 0.75, 0.5, 0.25), c(0.5, 0.75, 0.5, 0.25)]),
        GridTemplate(id: 'v6_bigL', name: 'Besar Kiri', cols: 3, rows: 3,
            cells: [c(0, 0, 0.6, 1), c(0.6, 0, 0.4, 0.2), c(0.6, 0.2, 0.4, 0.2), c(0.6, 0.4, 0.4, 0.2), c(0.6, 0.6, 0.4, 0.2), c(0.6, 0.8, 0.4, 0.2)]),
        GridTemplate(id: 'v6_mosaic', name: 'Mosaic', cols: 4, rows: 3,
            cells: [c(0, 0, 0.5, 0.5), c(0.5, 0, 0.5, 0.5),
                    c(0, 0.5, 0.25, 0.5), c(0.25, 0.5, 0.25, 0.5),
                    c(0.5, 0.5, 0.25, 0.5), c(0.75, 0.5, 0.25, 0.5)]),
        GridTemplate(id: 'v6_goldenT', name: 'Golden Atas', cols: 3, rows: 3,
            cells: [c(0, 0, 1, _g), c(0, _g, 0.333, 1 - _g), c(0.333, _g, 0.334, 1 - _g),
                    c(0.666, _g, 0.334, (1 - _g) / 2), c(0.666, _g + (1 - _g) / 2, 0.334, (1 - _g) / 2),
                    c(0, 0, 1, _g)]),
        GridTemplate(id: 'v6_corner', name: 'Pojok', cols: 4, rows: 4,
            cells: [c(0, 0, 0.5, 0.5), c(0.5, 0, 0.25, 0.25), c(0.75, 0, 0.25, 0.25),
                    c(0.5, 0.25, 0.25, 0.25), c(0.75, 0.25, 0.25, 0.25),
                    c(0, 0.5, 0.5, 0.5)]),
        GridTemplate(id: 'v6_pano', name: 'Panorama', cols: 3, rows: 3,
            cells: [c(0, 0, 1, 0.4), c(0, 0.4, 0.333, 0.3),
                    c(0.333, 0.4, 0.334, 0.3), c(0.666, 0.4, 0.334, 0.3),
                    c(0, 0.7, 0.5, 0.3), c(0.5, 0.7, 0.5, 0.3)]),
        GridTemplate(id: 'v6_strip', name: 'Strip', cols: 4, rows: 3,
            cells: [c(0, 0, 0.7, 1), c(0.7, 0, 0.3, 0.2), c(0.7, 0.2, 0.3, 0.2),
                    c(0.7, 0.4, 0.3, 0.2), c(0.7, 0.6, 0.3, 0.2), c(0.7, 0.8, 0.3, 0.2)]),
      ];

  // ============ 7 FOTO ============
  static List<GridTemplate> _v7() => [
        GridTemplate(id: 'v7_4_3', name: '4+3', cols: 4, rows: 2,
            cells: [c(0, 0, 0.25, 0.5), c(0.25, 0, 0.25, 0.5),
                    c(0.5, 0, 0.25, 0.5), c(0.75, 0, 0.25, 0.5),
                    c(0, 0.5, 0.333, 0.5), c(0.333, 0.5, 0.334, 0.5), c(0.666, 0.5, 0.334, 0.5)]),
        GridTemplate(id: 'v7_bigT', name: 'Besar Atas', cols: 3, rows: 3,
            cells: [c(0, 0, 1, 0.4), c(0, 0.4, 0.333, 0.3), c(0.333, 0.4, 0.334, 0.3),
                    c(0.666, 0.4, 0.334, 0.3), c(0, 0.7, 0.333, 0.3), c(0.333, 0.7, 0.334, 0.3),
                    c(0.666, 0.7, 0.334, 0.3)]),
        GridTemplate(id: 'v7_bigL', name: 'Besar Kiri', cols: 3, rows: 3,
            cells: [c(0, 0, 0.6, 1), c(0.6, 0, 0.4, 0.2), c(0.6, 0.2, 0.4, 0.2), c(0.6, 0.4, 0.4, 0.2), c(0.6, 0.6, 0.4, 0.2), c(0.6, 0.8, 0.2, 0.2), c(0.8, 0.8, 0.2, 0.2)]),
        GridTemplate(id: 'v7_mosaic', name: 'Mosaic', cols: 4, rows: 3,
            cells: [c(0, 0, 0.5, 0.5), c(0.5, 0, 0.25, 0.5), c(0.75, 0, 0.25, 0.5),
                    c(0, 0.5, 0.25, 0.5), c(0.25, 0.5, 0.25, 0.5),
                    c(0.5, 0.5, 0.25, 0.5), c(0.75, 0.5, 0.25, 0.5)]),
        GridTemplate(id: 'v7_goldenT', name: 'Golden Atas', cols: 4, rows: 3,
            cells: [c(0, 0, 1, _g), c(0, _g, 0.25, 1 - _g), c(0.25, _g, 0.25, 1 - _g),
                    c(0.5, _g, 0.25, 1 - _g), c(0.75, _g, 0.25, 1 - _g),
                    c(0, 0, 1, _g), c(0, 0, 1, _g)]),
        GridTemplate(id: 'v7_pano', name: 'Panorama', cols: 4, rows: 3,
            cells: [c(0, 0, 1, 0.4), c(0, 0.4, 0.25, 0.3), c(0.25, 0.4, 0.25, 0.3),
                    c(0.5, 0.4, 0.25, 0.3), c(0.75, 0.4, 0.25, 0.3),
                    c(0, 0.7, 0.5, 0.3), c(0.5, 0.7, 0.5, 0.3)]),
      ];

  // ============ 8 FOTO ============
  static List<GridTemplate> _v8() => [
        GridTemplate(id: 'v8_4x2', name: '4×2', cols: 4, rows: 2,
            cells: _uniformGrid(2, 4)),
        GridTemplate(id: 'v8_2x4', name: '2×4', cols: 2, rows: 4,
            cells: _uniformGrid(4, 2)),
        GridTemplate(id: 'v8_8x1', name: '8 Sebaris', cols: 8, rows: 1,
            cells: _uniformGrid(1, 8)),
        GridTemplate(id: 'v8_bigT', name: 'Besar Atas', cols: 4, rows: 3,
            cells: [c(0, 0, 1, 0.4),
                    c(0, 0.4, 0.25, 0.3), c(0.25, 0.4, 0.25, 0.3), c(0.5, 0.4, 0.25, 0.3), c(0.75, 0.4, 0.25, 0.3),
                    c(0, 0.7, 0.333, 0.3), c(0.333, 0.7, 0.334, 0.3), c(0.666, 0.7, 0.334, 0.3)]),
        GridTemplate(id: 'v8_bigL', name: 'Besar Kiri', cols: 4, rows: 3,
            cells: [c(0, 0, 0.5, 1), c(0.5, 0, 0.25, 0.25), c(0.75, 0, 0.25, 0.25),
                    c(0.5, 0.25, 0.25, 0.25), c(0.75, 0.25, 0.25, 0.25),
                    c(0.5, 0.5, 0.25, 0.25), c(0.75, 0.5, 0.25, 0.25),
                    c(0.5, 0.75, 0.5, 0.25)]),
        GridTemplate(id: 'v8_mosaic', name: 'Mosaic', cols: 4, rows: 4,
            cells: [c(0, 0, 0.5, 0.5), c(0.5, 0, 0.25, 0.5), c(0.75, 0, 0.25, 0.5),
                    c(0, 0.5, 0.25, 0.25), c(0.25, 0.5, 0.25, 0.25),
                    c(0.5, 0.5, 0.5, 0.5),
                    c(0, 0.75, 0.25, 0.25), c(0.25, 0.75, 0.25, 0.25)]),
        GridTemplate(id: 'v8_pano', name: 'Panorama', cols: 4, rows: 4,
            cells: [c(0, 0, 1, 0.35),
                    c(0, 0.35, 0.25, 0.3), c(0.25, 0.35, 0.25, 0.3), c(0.5, 0.35, 0.25, 0.3), c(0.75, 0.35, 0.25, 0.3),
                    c(0, 0.65, 0.333, 0.35), c(0.333, 0.65, 0.334, 0.35), c(0.666, 0.65, 0.334, 0.35)]),
        GridTemplate(id: 'v8_strip', name: 'Strip', cols: 4, rows: 4,
            cells: [c(0, 0, 0.7, 0.5), c(0.7, 0, 0.3, 0.25), c(0.7, 0.25, 0.3, 0.25),
                    c(0, 0.5, 0.25, 0.25), c(0.25, 0.5, 0.25, 0.25), c(0.5, 0.5, 0.2, 0.25),
                    c(0, 0.75, 0.35, 0.25), c(0.35, 0.75, 0.35, 0.25)]),
      ];

  // ============ 9 FOTO ============
  static List<GridTemplate> _v9() => [
        GridTemplate(id: 'v9_3x3', name: '3×3', cols: 3, rows: 3,
            cells: _uniformGrid(3, 3)),
        GridTemplate(id: 'v9_bigT', name: 'Besar Atas', cols: 3, rows: 4,
            cells: [c(0, 0, 1, 0.4),
                    c(0, 0.4, 0.333, 0.2), c(0.333, 0.4, 0.334, 0.2), c(0.666, 0.4, 0.334, 0.2),
                    c(0, 0.6, 0.333, 0.2), c(0.333, 0.6, 0.334, 0.2), c(0.666, 0.6, 0.334, 0.2),
                    c(0, 0.8, 0.5, 0.2), c(0.5, 0.8, 0.5, 0.2)]),
        GridTemplate(id: 'v9_bigC', name: 'Besar Tengah', cols: 3, rows: 4,
            cells: [c(0, 0, 0.333, 0.25), c(0.333, 0, 0.334, 0.25), c(0.666, 0, 0.334, 0.25),
                    c(0, 0.25, 0.333, 0.25), c(0.666, 0.25, 0.334, 0.25),
                    c(0.333, 0.25, 0.334, 0.5),
                    c(0, 0.5, 0.333, 0.5), c(0.333, 0.75, 0.334, 0.25), c(0.666, 0.5, 0.334, 0.5)]),
        GridTemplate(id: 'v9_mosaic', name: 'Mosaic', cols: 4, rows: 4,
            cells: [c(0, 0, 0.5, 0.5), c(0.5, 0, 0.25, 0.25), c(0.75, 0, 0.25, 0.25),
                    c(0.5, 0.25, 0.25, 0.25), c(0.75, 0.25, 0.25, 0.25),
                    c(0, 0.5, 0.25, 0.25), c(0.25, 0.5, 0.25, 0.25),
                    c(0.5, 0.5, 0.5, 0.5),
                    c(0, 0.75, 0.25, 0.25)]),
        GridTemplate(id: 'v9_golden', name: 'Golden', cols: 4, rows: 4,
            cells: [c(0, 0, _g, _g), c(_g, 0, 1 - _g, 0.333), c(_g, 0.333, 1 - _g, 0.333),
                    c(_g, 0.666, 1 - _g, 1 - _g - 0.666 + 0.001),
                    c(0, _g, 0.25, 1 - _g), c(0.25, _g, 0.25, 1 - _g),
                    c(0.5, _g, (1 - _g) / 2, 0.5), c(0.5, _g + 0.5, (1 - _g) / 2, 1 - _g - 0.5),
                    c(0, 0.9, 0.5, 0.1)]),
        GridTemplate(id: 'v9_pano', name: 'Panorama', cols: 3, rows: 4,
            cells: [c(0, 0, 1, 0.3),
                    c(0, 0.3, 0.333, 0.25), c(0.333, 0.3, 0.334, 0.25), c(0.666, 0.3, 0.334, 0.25),
                    c(0, 0.55, 0.25, 0.25), c(0.25, 0.55, 0.25, 0.25), c(0.5, 0.55, 0.25, 0.25), c(0.75, 0.55, 0.25, 0.25),
                    c(0, 0.8, 1, 0.2)]),
        GridTemplate(id: 'v9_strip', name: 'Strip', cols: 4, rows: 4,
            cells: [c(0, 0, 0.5, 0.5), c(0.5, 0, 0.25, 0.25), c(0.75, 0, 0.25, 0.25),
                    c(0.5, 0.25, 0.25, 0.25), c(0.75, 0.25, 0.25, 0.25),
                    c(0, 0.5, 0.25, 0.25), c(0.25, 0.5, 0.25, 0.25),
                    c(0.5, 0.5, 0.25, 0.5), c(0.75, 0.5, 0.25, 0.5)]),
      ];

  // ============ 10-20 FOTO (ringkas — fokus tambah jenis layout) ============
  static List<GridTemplate> _v10() => [
        GridTemplate(id: 'v10_5x2', name: '5×2', cols: 5, rows: 2, cells: _uniformGrid(2, 5)),
        GridTemplate(id: 'v10_2x5', name: '2×5', cols: 2, rows: 5, cells: _uniformGrid(5, 2)),
        GridTemplate(id: 'v10_343', name: '3-4-3', cols: 4, rows: 3,
            cells: [c(0, 0, 0.333, 0.333), c(0.333, 0, 0.334, 0.333), c(0.666, 0, 0.334, 0.333),
                    c(0, 0.333, 0.25, 0.334), c(0.25, 0.333, 0.25, 0.334), c(0.5, 0.333, 0.25, 0.334), c(0.75, 0.333, 0.25, 0.334),
                    c(0, 0.667, 0.333, 0.333), c(0.333, 0.667, 0.334, 0.333), c(0.666, 0.667, 0.334, 0.333)]),
        GridTemplate(id: 'v10_mosaic', name: 'Mosaic', cols: 5, rows: 3,
            cells: [c(0, 0, 0.5, 0.6), c(0.5, 0, 0.25, 0.3), c(0.75, 0, 0.25, 0.3), c(0.5, 0.3, 0.25, 0.3), c(0.75, 0.3, 0.25, 0.3), c(0, 0.6, 0.25, 0.4), c(0.25, 0.6, 0.25, 0.4), c(0.5, 0.6, 0.25, 0.4), c(0.75, 0.6, 0.25, 0.4), c(0.5, 0, 0.25, 0.3)]),
        GridTemplate(id: 'v10_pano', name: 'Panorama', cols: 5, rows: 3,
            cells: [c(0, 0, 1, 0.3),
                    c(0, 0.3, 0.2, 0.35), c(0.2, 0.3, 0.2, 0.35), c(0.4, 0.3, 0.2, 0.35), c(0.6, 0.3, 0.2, 0.35), c(0.8, 0.3, 0.2, 0.35),
                    c(0, 0.65, 0.25, 0.35), c(0.25, 0.65, 0.25, 0.35), c(0.5, 0.65, 0.25, 0.35), c(0.75, 0.65, 0.25, 0.35)]),
      ];

  static List<GridTemplate> _v11() => [
        GridTemplate(id: 'v11_443', name: '4-4-3', cols: 4, rows: 3,
            cells: [c(0, 0, 0.25, 0.333), c(0.25, 0, 0.25, 0.333), c(0.5, 0, 0.25, 0.333), c(0.75, 0, 0.25, 0.333),
                    c(0, 0.333, 0.25, 0.334), c(0.25, 0.333, 0.25, 0.334), c(0.5, 0.333, 0.25, 0.334), c(0.75, 0.333, 0.25, 0.334),
                    c(0, 0.667, 0.333, 0.333), c(0.333, 0.667, 0.334, 0.333), c(0.666, 0.667, 0.334, 0.333)]),
        GridTemplate(id: 'v11_bigT', name: 'Besar Atas', cols: 4, rows: 4,
            cells: [c(0, 0, 1, 0.35),
                    c(0, 0.35, 0.25, 0.2), c(0.25, 0.35, 0.25, 0.2), c(0.5, 0.35, 0.25, 0.2), c(0.75, 0.35, 0.25, 0.2),
                    c(0, 0.55, 0.25, 0.225), c(0.25, 0.55, 0.25, 0.225), c(0.5, 0.55, 0.25, 0.225), c(0.75, 0.55, 0.25, 0.225),
                    c(0, 0.775, 0.5, 0.225), c(0.5, 0.775, 0.5, 0.225)]),
        GridTemplate(id: 'v11_mosaic', name: 'Mosaic', cols: 4, rows: 4,
            cells: [c(0, 0, 0.5, 0.5), c(0.5, 0, 0.25, 0.25), c(0.75, 0, 0.25, 0.25),
                    c(0.5, 0.25, 0.25, 0.25), c(0.75, 0.25, 0.25, 0.25),
                    c(0, 0.5, 0.25, 0.25), c(0.25, 0.5, 0.25, 0.25),
                    c(0.5, 0.5, 0.25, 0.5), c(0.75, 0.5, 0.25, 0.5),
                    c(0, 0.75, 0.25, 0.25), c(0.25, 0.75, 0.25, 0.25)]),
      ];

  static List<GridTemplate> _v12() => [
        GridTemplate(id: 'v12_4x3', name: '4×3', cols: 4, rows: 3, cells: _uniformGrid(3, 4)),
        GridTemplate(id: 'v12_3x4', name: '3×4', cols: 3, rows: 4, cells: _uniformGrid(4, 3)),
        GridTemplate(id: 'v12_6x2', name: '6×2', cols: 6, rows: 2, cells: _uniformGrid(2, 6)),
        GridTemplate(id: 'v12_bigT', name: 'Besar Atas', cols: 4, rows: 4,
            cells: [c(0, 0, 1, 0.35),
                    c(0, 0.35, 0.25, 0.2), c(0.25, 0.35, 0.25, 0.2), c(0.5, 0.35, 0.25, 0.2), c(0.75, 0.35, 0.25, 0.2),
                    c(0, 0.55, 0.25, 0.225), c(0.25, 0.55, 0.25, 0.225), c(0.5, 0.55, 0.25, 0.225), c(0.75, 0.55, 0.25, 0.225),
                    c(0, 0.775, 0.333, 0.225), c(0.333, 0.775, 0.334, 0.225), c(0.666, 0.775, 0.334, 0.225)]),
        GridTemplate(id: 'v12_mosaic', name: 'Mosaic', cols: 5, rows: 3,
            cells: [c(0, 0, 0.5, 0.5), c(0.5, 0, 0.25, 0.25), c(0.75, 0, 0.25, 0.25), c(0.5, 0.25, 0.25, 0.25), c(0.75, 0.25, 0.25, 0.25), c(0, 0.5, 0.25, 0.25), c(0.25, 0.5, 0.25, 0.25), c(0.5, 0.5, 0.25, 0.25), c(0.75, 0.5, 0.25, 0.25), c(0, 0.75, 0.25, 0.25), c(0.25, 0.75, 0.25, 0.25), c(0.5, 0.75, 0.5, 0.25)]),
      ];

  static List<GridTemplate> _v13() => [
        GridTemplate(id: 'v13_544', name: '5-4-4', cols: 5, rows: 3,
            cells: [c(0, 0, 0.2, 0.333), c(0.2, 0, 0.2, 0.333), c(0.4, 0, 0.2, 0.333), c(0.6, 0, 0.2, 0.333), c(0.8, 0, 0.2, 0.333),
                    c(0, 0.333, 0.25, 0.334), c(0.25, 0.333, 0.25, 0.334), c(0.5, 0.333, 0.25, 0.334), c(0.75, 0.333, 0.25, 0.334),
                    c(0, 0.667, 0.25, 0.333), c(0.25, 0.667, 0.25, 0.333), c(0.5, 0.667, 0.25, 0.333), c(0.75, 0.667, 0.25, 0.333)]),
        GridTemplate(id: 'v13_bigT', name: 'Besar Atas', cols: 4, rows: 4,
            cells: [c(0, 0, 1, 0.35),
                    c(0, 0.35, 0.25, 0.2), c(0.25, 0.35, 0.25, 0.2), c(0.5, 0.35, 0.25, 0.2), c(0.75, 0.35, 0.25, 0.2),
                    c(0, 0.55, 0.25, 0.225), c(0.25, 0.55, 0.25, 0.225), c(0.5, 0.55, 0.25, 0.225), c(0.75, 0.55, 0.25, 0.225),
                    c(0, 0.775, 0.25, 0.225), c(0.25, 0.775, 0.25, 0.225), c(0.5, 0.775, 0.25, 0.225), c(0.75, 0.775, 0.25, 0.225)]),
      ];

  static List<GridTemplate> _v14() => [
        GridTemplate(id: 'v14_7x2', name: '7×2', cols: 7, rows: 2, cells: _uniformGrid(2, 7)),
        GridTemplate(id: 'v14_bigT', name: 'Besar Atas', cols: 4, rows: 4,
            cells: [c(0, 0, 1, 0.35),
                    c(0, 0.35, 0.25, 0.2), c(0.25, 0.35, 0.25, 0.2), c(0.5, 0.35, 0.25, 0.2), c(0.75, 0.35, 0.25, 0.2),
                    c(0, 0.55, 0.25, 0.2), c(0.25, 0.55, 0.25, 0.2), c(0.5, 0.55, 0.25, 0.2), c(0.75, 0.55, 0.25, 0.2),
                    c(0, 0.75, 0.2, 0.25), c(0.2, 0.75, 0.2, 0.25), c(0.4, 0.75, 0.2, 0.25), c(0.6, 0.75, 0.2, 0.25), c(0.8, 0.75, 0.2, 0.25)]),
      ];

  static List<GridTemplate> _v15() => [
        GridTemplate(id: 'v15_5x3', name: '5×3', cols: 5, rows: 3, cells: _uniformGrid(3, 5)),
        GridTemplate(id: 'v15_3x5', name: '3×5', cols: 3, rows: 5, cells: _uniformGrid(5, 3)),
        GridTemplate(id: 'v15_bigT', name: 'Besar Atas', cols: 5, rows: 4,
            cells: [c(0, 0, 1, 0.3),
                    c(0, 0.3, 0.2, 0.233), c(0.2, 0.3, 0.2, 0.233), c(0.4, 0.3, 0.2, 0.233), c(0.6, 0.3, 0.2, 0.233), c(0.8, 0.3, 0.2, 0.233),
                    c(0, 0.533, 0.2, 0.234), c(0.2, 0.533, 0.2, 0.234), c(0.4, 0.533, 0.2, 0.234), c(0.6, 0.533, 0.2, 0.234), c(0.8, 0.533, 0.2, 0.234),
                    c(0, 0.767, 0.25, 0.233), c(0.25, 0.767, 0.25, 0.233), c(0.5, 0.767, 0.25, 0.233), c(0.75, 0.767, 0.25, 0.233)]),
      ];

  static List<GridTemplate> _v16() => [
        GridTemplate(id: 'v16_4x4', name: '4×4', cols: 4, rows: 4, cells: _uniformGrid(4, 4)),
        GridTemplate(id: 'v16_8x2', name: '8×2', cols: 8, rows: 2, cells: _uniformGrid(2, 8)),
        GridTemplate(id: 'v16_2x8', name: '2×8', cols: 2, rows: 8, cells: _uniformGrid(8, 2)),
        GridTemplate(id: 'v16_bigT', name: 'Besar Atas', cols: 4, rows: 5,
            cells: [c(0, 0, 1, 0.3),
                    c(0, 0.3, 0.25, 0.175), c(0.25, 0.3, 0.25, 0.175), c(0.5, 0.3, 0.25, 0.175), c(0.75, 0.3, 0.25, 0.175),
                    c(0, 0.475, 0.25, 0.175), c(0.25, 0.475, 0.25, 0.175), c(0.5, 0.475, 0.25, 0.175), c(0.75, 0.475, 0.25, 0.175),
                    c(0, 0.65, 0.25, 0.175), c(0.25, 0.65, 0.25, 0.175), c(0.5, 0.65, 0.25, 0.175), c(0.75, 0.65, 0.25, 0.175),
                    c(0, 0.825, 0.333, 0.175), c(0.333, 0.825, 0.334, 0.175), c(0.666, 0.825, 0.334, 0.175)]),
      ];

  static List<GridTemplate> _v17() => [
        GridTemplate(id: 'v17_bigT', name: 'Besar Atas', cols: 4, rows: 5,
            cells: [c(0, 0, 1, 0.25),
                    c(0, 0.25, 0.25, 0.15), c(0.25, 0.25, 0.25, 0.15), c(0.5, 0.25, 0.25, 0.15), c(0.75, 0.25, 0.25, 0.15),
                    c(0, 0.4, 0.25, 0.15), c(0.25, 0.4, 0.25, 0.15), c(0.5, 0.4, 0.25, 0.15), c(0.75, 0.4, 0.25, 0.15),
                    c(0, 0.55, 0.25, 0.225), c(0.25, 0.55, 0.25, 0.225), c(0.5, 0.55, 0.25, 0.225), c(0.75, 0.55, 0.25, 0.225),
                    c(0, 0.775, 0.25, 0.225), c(0.25, 0.775, 0.25, 0.225), c(0.5, 0.775, 0.25, 0.225), c(0.75, 0.775, 0.25, 0.225)]),
      ];

  static List<GridTemplate> _v18() => [
        GridTemplate(id: 'v18_6x3', name: '6×3', cols: 6, rows: 3, cells: _uniformGrid(3, 6)),
        GridTemplate(id: 'v18_3x6', name: '3×6', cols: 3, rows: 6, cells: _uniformGrid(6, 3)),
        GridTemplate(id: 'v18_9x2', name: '9×2', cols: 9, rows: 2, cells: _uniformGrid(2, 9)),
      ];

  static List<GridTemplate> _v19() => [
        GridTemplate(id: 'v19_bigT', name: 'Besar Atas', cols: 6, rows: 4,
            cells: [c(0, 0, 1, 0.25),
                    c(0, 0.25, 0.166, 0.25), c(0.166, 0.25, 0.167, 0.25), c(0.333, 0.25, 0.167, 0.25),
                    c(0.5, 0.25, 0.167, 0.25), c(0.667, 0.25, 0.166, 0.25), c(0.833, 0.25, 0.167, 0.25),
                    c(0, 0.5, 0.166, 0.25), c(0.166, 0.5, 0.167, 0.25), c(0.333, 0.5, 0.167, 0.25),
                    c(0.5, 0.5, 0.167, 0.25), c(0.667, 0.5, 0.166, 0.25), c(0.833, 0.5, 0.167, 0.25),
                    c(0, 0.75, 0.166, 0.25), c(0.166, 0.75, 0.167, 0.25), c(0.333, 0.75, 0.167, 0.25),
                    c(0.5, 0.75, 0.167, 0.25), c(0.667, 0.75, 0.166, 0.25), c(0.833, 0.75, 0.167, 0.25)]),
        GridTemplate(id: 'v19_10x2', name: '10×2', cols: 10, rows: 2, cells: _uniformGrid(2, 10)),
      ];

  static List<GridTemplate> _v20() => [
        GridTemplate(id: 'v20_5x4', name: '5×4', cols: 5, rows: 4, cells: _uniformGrid(4, 5)),
        GridTemplate(id: 'v20_4x5', name: '4×5', cols: 4, rows: 5, cells: _uniformGrid(5, 4)),
        GridTemplate(id: 'v20_10x2', name: '10×2', cols: 10, rows: 2, cells: _uniformGrid(2, 10)),
        GridTemplate(id: 'v20_2x10', name: '2×10', cols: 2, rows: 10, cells: _uniformGrid(10, 2)),
        GridTemplate(id: 'v20_bigT', name: 'Besar Atas', cols: 5, rows: 5,
            cells: [c(0, 0, 1, 0.25),
                    c(0, 0.25, 0.2, 0.1875), c(0.2, 0.25, 0.2, 0.1875), c(0.4, 0.25, 0.2, 0.1875), c(0.6, 0.25, 0.2, 0.1875), c(0.8, 0.25, 0.2, 0.1875),
                    c(0, 0.4375, 0.2, 0.1875), c(0.2, 0.4375, 0.2, 0.1875), c(0.4, 0.4375, 0.2, 0.1875), c(0.6, 0.4375, 0.2, 0.1875), c(0.8, 0.4375, 0.2, 0.1875),
                    c(0, 0.625, 0.2, 0.1875), c(0.2, 0.625, 0.2, 0.1875), c(0.4, 0.625, 0.2, 0.1875), c(0.6, 0.625, 0.2, 0.1875), c(0.8, 0.625, 0.2, 0.1875),
                    c(0, 0.8125, 0.333, 0.1875), c(0.333, 0.8125, 0.334, 0.1875), c(0.666, 0.8125, 0.334, 0.1875), c(0, 0, 1, 0.25)]),
      ];
}
