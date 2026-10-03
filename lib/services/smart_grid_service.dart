import '../models/grid_template.dart';

/// Service untuk generate template grid berdasarkan jumlah foto.
/// Support 1-20 foto, dengan beberapa varian layout per count.
class SmartGridService {
  /// Backward-compat: return varian pertama.
  static GridTemplate forPhotoCount(int count) {
    final variants = variantsFor(count);
    return variants.first;
  }

  /// Return daftar varian template yang cocok untuk jumlah foto `count`.
  /// Setiap template punya `cellCount == count`.
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

  /// Grid seragam: rows × cols
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

  // ============ VARIAN 1 FOTO ============
  static List<GridTemplate> _v1() => [
        GridTemplate(id: 'v1_full', name: '1 Foto', cols: 1, rows: 1,
            cells: [c(0, 0, 1, 1)]),
      ];

  // ============ VARIAN 2 FOTO ============
  static List<GridTemplate> _v2() => [
        GridTemplate(id: 'v2_h', name: '2 Samping', cols: 2, rows: 1,
            cells: [c(0, 0, 0.5, 1), c(0.5, 0, 0.5, 1)]),
        GridTemplate(id: 'v2_v', name: '2 Tumpuk', cols: 1, rows: 2,
            cells: [c(0, 0, 1, 0.5), c(0, 0.5, 1, 0.5)]),
        GridTemplate(id: 'v2_bigL', name: 'Besar Kiri', cols: 2, rows: 1,
            cells: [c(0, 0, 0.65, 1), c(0.65, 0, 0.35, 1)]),
      ];

  // ============ VARIAN 3 FOTO ============
  static List<GridTemplate> _v3() => [
        GridTemplate(id: 'v3_bigL', name: 'Besar Kiri', cols: 2, rows: 2,
            cells: [c(0, 0, 0.5, 1), c(0.5, 0, 0.5, 0.5), c(0.5, 0.5, 0.5, 0.5)]),
        GridTemplate(id: 'v3_bigT', name: 'Besar Atas', cols: 2, rows: 2,
            cells: [c(0, 0, 1, 0.6), c(0, 0.6, 0.5, 0.4), c(0.5, 0.6, 0.5, 0.4)]),
        GridTemplate(id: 'v3_row', name: '3 Sebaris', cols: 3, rows: 1,
            cells: [c(0, 0, 0.333, 1), c(0.333, 0, 0.334, 1), c(0.666, 0, 0.334, 1)]),
        GridTemplate(id: 'v3_col', name: '3 Setumpuk', cols: 1, rows: 3,
            cells: [c(0, 0, 1, 0.333), c(0, 0.333, 1, 0.334), c(0, 0.667, 1, 0.334)]),
      ];

  // ============ VARIAN 4 FOTO ============
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
      ];

  // ============ VARIAN 5 FOTO ============
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
      ];

  // ============ VARIAN 6 FOTO ============
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
      ];

  // ============ VARIAN 7 FOTO ============
  static List<GridTemplate> _v7() => [
        GridTemplate(id: 'v7_4_3', name: '4+3', cols: 4, rows: 2,
            cells: [c(0, 0, 0.25, 0.5), c(0.25, 0, 0.25, 0.5),
                    c(0.5, 0, 0.25, 0.5), c(0.75, 0, 0.25, 0.5),
                    c(0, 0.5, 0.333, 0.5), c(0.333, 0.5, 0.334, 0.5), c(0.666, 0.5, 0.334, 0.5)]),
        GridTemplate(id: 'v7_bigT', name: 'Besar Atas', cols: 3, rows: 3,
            cells: [c(0, 0, 1, 0.4), c(0, 0.4, 0.333, 0.3), c(0.333, 0.4, 0.334, 0.3),
                    c(0.666, 0.4, 0.334, 0.3), c(0, 0.7, 0.333, 0.3), c(0.333, 0.7, 0.334, 0.3),
                    c(0.666, 0.7, 0.334, 0.3)]),
      ];

  // ============ VARIAN 8 FOTO ============
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
      ];

  // ============ VARIAN 9 FOTO ============
  static List<GridTemplate> _v9() => [
        GridTemplate(id: 'v9_3x3', name: '3×3', cols: 3, rows: 3,
            cells: _uniformGrid(3, 3)),
        GridTemplate(id: 'v9_bigT', name: 'Besar Atas', cols: 3, rows: 4,
            cells: [c(0, 0, 1, 0.4),
                    c(0, 0.4, 0.333, 0.2), c(0.333, 0.4, 0.334, 0.2), c(0.666, 0.4, 0.334, 0.2),
                    c(0, 0.6, 0.333, 0.2), c(0.333, 0.6, 0.334, 0.2), c(0.666, 0.6, 0.334, 0.2),
                    c(0, 0.8, 0.5, 0.2), c(0.5, 0.8, 0.5, 0.2)]),
      ];

  // ============ VARIAN 10 FOTO ============
  static List<GridTemplate> _v10() => [
        GridTemplate(id: 'v10_5x2', name: '5×2', cols: 5, rows: 2,
            cells: _uniformGrid(2, 5)),
        GridTemplate(id: 'v10_2x5', name: '2×5', cols: 2, rows: 5,
            cells: _uniformGrid(5, 2)),
        GridTemplate(id: 'v10_343', name: '3-4-3', cols: 4, rows: 3,
            cells: [c(0, 0, 0.333, 0.333), c(0.333, 0, 0.334, 0.333), c(0.666, 0, 0.334, 0.333),
                    c(0, 0.333, 0.25, 0.334), c(0.25, 0.333, 0.25, 0.334), c(0.5, 0.333, 0.25, 0.334), c(0.75, 0.333, 0.25, 0.334),
                    c(0, 0.667, 0.333, 0.333), c(0.333, 0.667, 0.334, 0.333), c(0.666, 0.667, 0.334, 0.333)]),
      ];

  // ============ VARIAN 11 FOTO ============
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
      ];

  // ============ VARIAN 12 FOTO ============
  static List<GridTemplate> _v12() => [
        GridTemplate(id: 'v12_4x3', name: '4×3', cols: 4, rows: 3,
            cells: _uniformGrid(3, 4)),
        GridTemplate(id: 'v12_3x4', name: '3×4', cols: 3, rows: 4,
            cells: _uniformGrid(4, 3)),
        GridTemplate(id: 'v12_6x2', name: '6×2', cols: 6, rows: 2,
            cells: _uniformGrid(2, 6)),
        GridTemplate(id: 'v12_444', name: '4-4-4', cols: 4, rows: 3,
            cells: _uniformGrid(3, 4)),
      ];

  // ============ VARIAN 13 FOTO ============
  static List<GridTemplate> _v13() => [
        GridTemplate(id: 'v13_bigT', name: 'Besar Atas', cols: 4, rows: 4,
            cells: [c(0, 0, 1, 0.35),
                    c(0, 0.35, 0.25, 0.2), c(0.25, 0.35, 0.25, 0.2), c(0.5, 0.35, 0.25, 0.2), c(0.75, 0.35, 0.25, 0.2),
                    c(0, 0.55, 0.25, 0.225), c(0.25, 0.55, 0.25, 0.225), c(0.5, 0.55, 0.25, 0.225), c(0.75, 0.55, 0.25, 0.225),
                    c(0, 0.775, 0.25, 0.225), c(0.25, 0.775, 0.25, 0.225), c(0.5, 0.775, 0.25, 0.225), c(0.75, 0.775, 0.25, 0.225)]),
        GridTemplate(id: 'v13_544', name: '5-4-4', cols: 5, rows: 3,
            cells: [c(0, 0, 0.2, 0.333), c(0.2, 0, 0.2, 0.333), c(0.4, 0, 0.2, 0.333), c(0.6, 0, 0.2, 0.333), c(0.8, 0, 0.2, 0.333),
                    c(0, 0.333, 0.25, 0.334), c(0.25, 0.333, 0.25, 0.334), c(0.5, 0.333, 0.25, 0.334), c(0.75, 0.333, 0.25, 0.334),
                    c(0, 0.667, 0.25, 0.333), c(0.25, 0.667, 0.25, 0.333), c(0.5, 0.667, 0.25, 0.333), c(0.75, 0.667, 0.25, 0.333)]),
      ];

  // ============ VARIAN 14 FOTO ============
  static List<GridTemplate> _v14() => [
        GridTemplate(id: 'v14_bigT', name: 'Besar Atas', cols: 4, rows: 4,
            cells: [c(0, 0, 1, 0.35),
                    c(0, 0.35, 0.25, 0.2), c(0.25, 0.35, 0.25, 0.2), c(0.5, 0.35, 0.25, 0.2), c(0.75, 0.35, 0.25, 0.2),
                    c(0, 0.55, 0.25, 0.2), c(0.25, 0.55, 0.25, 0.2), c(0.5, 0.55, 0.25, 0.2), c(0.75, 0.55, 0.25, 0.2),
                    c(0, 0.75, 0.2, 0.25), c(0.2, 0.75, 0.2, 0.25), c(0.4, 0.75, 0.2, 0.25), c(0.6, 0.75, 0.2, 0.25), c(0.8, 0.75, 0.2, 0.25)]),
        GridTemplate(id: 'v14_77', name: '7×2', cols: 7, rows: 2,
            cells: _uniformGrid(2, 7)),
      ];

  // ============ VARIAN 15 FOTO ============
  static List<GridTemplate> _v15() => [
        GridTemplate(id: 'v15_5x3', name: '5×3', cols: 5, rows: 3,
            cells: _uniformGrid(3, 5)),
        GridTemplate(id: 'v15_3x5', name: '3×5', cols: 3, rows: 5,
            cells: _uniformGrid(5, 3)),
        GridTemplate(id: 'v15_bigT', name: 'Besar Atas', cols: 5, rows: 4,
            cells: [c(0, 0, 1, 0.3),
                    c(0, 0.3, 0.2, 0.233), c(0.2, 0.3, 0.2, 0.233), c(0.4, 0.3, 0.2, 0.233), c(0.6, 0.3, 0.2, 0.233), c(0.8, 0.3, 0.2, 0.233),
                    c(0, 0.533, 0.2, 0.234), c(0.2, 0.533, 0.2, 0.234), c(0.4, 0.533, 0.2, 0.234), c(0.6, 0.533, 0.2, 0.234), c(0.8, 0.533, 0.2, 0.234),
                    c(0, 0.767, 0.25, 0.233), c(0.25, 0.767, 0.25, 0.233), c(0.5, 0.767, 0.25, 0.233), c(0.75, 0.767, 0.25, 0.233)]),
      ];

  // ============ VARIAN 16 FOTO ============
  static List<GridTemplate> _v16() => [
        GridTemplate(id: 'v16_4x4', name: '4×4', cols: 4, rows: 4,
            cells: _uniformGrid(4, 4)),
        GridTemplate(id: 'v16_8x2', name: '8×2', cols: 8, rows: 2,
            cells: _uniformGrid(2, 8)),
        GridTemplate(id: 'v16_2x8', name: '2×8', cols: 2, rows: 8,
            cells: _uniformGrid(8, 2)),
      ];

  // ============ VARIAN 17 FOTO ============
  static List<GridTemplate> _v17() => [
        GridTemplate(id: 'v17_bigT', name: 'Besar Atas', cols: 4, rows: 5,
            cells: [c(0, 0, 1, 0.25),
                    c(0, 0.25, 0.25, 0.15), c(0.25, 0.25, 0.25, 0.15), c(0.5, 0.25, 0.25, 0.15), c(0.75, 0.25, 0.25, 0.15),
                    c(0, 0.4, 0.25, 0.15), c(0.25, 0.4, 0.25, 0.15), c(0.5, 0.4, 0.25, 0.15), c(0.75, 0.4, 0.25, 0.15),
                    c(0, 0.55, 0.25, 0.225), c(0.25, 0.55, 0.25, 0.225), c(0.5, 0.55, 0.25, 0.225), c(0.75, 0.55, 0.25, 0.225),
                    c(0, 0.775, 0.25, 0.225), c(0.25, 0.775, 0.25, 0.225), c(0.5, 0.775, 0.25, 0.225), c(0.75, 0.775, 0.25, 0.225)]),
      ];

  // ============ VARIAN 18 FOTO ============
  static List<GridTemplate> _v18() => [
        GridTemplate(id: 'v18_6x3', name: '6×3', cols: 6, rows: 3,
            cells: _uniformGrid(3, 6)),
        GridTemplate(id: 'v18_3x6', name: '3×6', cols: 3, rows: 6,
            cells: _uniformGrid(6, 3)),
        GridTemplate(id: 'v18_9x2', name: '9×2', cols: 9, rows: 2,
            cells: _uniformGrid(2, 9)),
      ];

  // ============ VARIAN 19 FOTO ============
  static List<GridTemplate> _v19() => [
        GridTemplate(id: 'v19_bigT', name: 'Besar Atas', cols: 6, rows: 4,
            cells: [c(0, 0, 1, 0.25),
                    c(0, 0.25, 0.166, 0.25), c(0.166, 0.25, 0.167, 0.25), c(0.333, 0.25, 0.167, 0.25),
                    c(0.5, 0.25, 0.167, 0.25), c(0.667, 0.25, 0.166, 0.25), c(0.833, 0.25, 0.167, 0.25),
                    c(0, 0.5, 0.166, 0.25), c(0.166, 0.5, 0.167, 0.25), c(0.333, 0.5, 0.167, 0.25),
                    c(0.5, 0.5, 0.167, 0.25), c(0.667, 0.5, 0.166, 0.25), c(0.833, 0.5, 0.167, 0.25),
                    c(0, 0.75, 0.166, 0.25), c(0.166, 0.75, 0.167, 0.25), c(0.333, 0.75, 0.167, 0.25),
                    c(0.5, 0.75, 0.167, 0.25), c(0.667, 0.75, 0.166, 0.25), c(0.833, 0.75, 0.167, 0.25)]),
        GridTemplate(id: 'v19_10x2', name: '10×2', cols: 10, rows: 2,
            cells: _uniformGrid(2, 10)),
      ];

  // ============ VARIAN 20 FOTO ============
  static List<GridTemplate> _v20() => [
        GridTemplate(id: 'v20_5x4', name: '5×4', cols: 5, rows: 4,
            cells: _uniformGrid(4, 5)),
        GridTemplate(id: 'v20_4x5', name: '4×5', cols: 4, rows: 5,
            cells: _uniformGrid(5, 4)),
        GridTemplate(id: 'v20_10x2', name: '10×2', cols: 10, rows: 2,
            cells: _uniformGrid(2, 10)),
        GridTemplate(id: 'v20_2x10', name: '2×10', cols: 2, rows: 10,
            cells: _uniformGrid(10, 2)),
      ];
}
