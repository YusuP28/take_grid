import '../models/grid_template.dart';

class SmartGridService {
  /// Generate template berdasarkan jumlah foto (1-12)
  static GridTemplate forPhotoCount(int count) {
    switch (count) {
      case 1:
        return _single();
      case 2:
        return _two();
      case 3:
        return _three();
      case 4:
        return _four();
      case 5:
        return _five();
      case 6:
        return _six();
      case 7:
        return _seven();
      case 8:
        return _eight();
      case 9:
        return _nine();
      case 10:
        return _ten();
      case 11:
        return _eleven();
      case 12:
        return _twelve();
      default:
        return _four();
    }
  }

  // ============ HELPERS ============
  static GridCell c(double x, double y, double w, double h) =>
      GridCell(x: x, y: y, w: w, h: h);

  // ============ TEMPLATES ============
  static GridTemplate _single() => GridTemplate(
        id: 'smart_1',
        name: '1 Foto',
        cols: 1, rows: 1,
        cells: [c(0, 0, 1, 1)],
      );

  static GridTemplate _two() => GridTemplate(
        id: 'smart_2',
        name: '2 Foto',
        cols: 2, rows: 1,
        cells: [c(0, 0, 0.5, 1), c(0.5, 0, 0.5, 1)],
      );

  static GridTemplate _three() => GridTemplate(
        id: 'smart_3',
        name: '3 Foto (Big Left)',
        cols: 2, rows: 2,
        cells: [
          c(0, 0, 0.5, 1),      // big left
          c(0.5, 0, 0.5, 0.5),
          c(0.5, 0.5, 0.5, 0.5),
        ],
      );

  static GridTemplate _four() => GridTemplate(
        id: 'smart_4',
        name: '4 Foto (2x2)',
        cols: 2, rows: 2,
        cells: [
          c(0, 0, 0.5, 0.5), c(0.5, 0, 0.5, 0.5),
          c(0, 0.5, 0.5, 0.5), c(0.5, 0.5, 0.5, 0.5),
        ],
      );

  static GridTemplate _five() => GridTemplate(
        id: 'smart_5',
        name: '5 Foto (Big Center)',
        cols: 3, rows: 3,
        cells: [
          c(0, 0, 0.333, 0.5), c(0.333, 0, 0.334, 0.5), c(0.666, 0, 0.334, 0.5),
          c(0, 0.5, 0.5, 0.5),   c(0.5, 0.5, 0.5, 0.5),
        ],
      );

  static GridTemplate _six() => GridTemplate(
        id: 'smart_6',
        name: '6 Foto (3x2)',
        cols: 3, rows: 2,
        cells: [
          c(0, 0, 0.333, 0.5), c(0.333, 0, 0.334, 0.5), c(0.666, 0, 0.334, 0.5),
          c(0, 0.5, 0.333, 0.5), c(0.333, 0.5, 0.334, 0.5), c(0.666, 0.5, 0.334, 0.5),
        ],
      );

  static GridTemplate _seven() => GridTemplate(
        id: 'smart_7',
        name: '7 Foto',
        cols: 4, rows: 2,
        cells: [
          c(0, 0, 0.25, 0.5), c(0.25, 0, 0.25, 0.5),
          c(0.5, 0, 0.25, 0.5), c(0.75, 0, 0.25, 0.5),
          c(0, 0.5, 0.333, 0.5), c(0.333, 0.5, 0.334, 0.5), c(0.666, 0.5, 0.334, 0.5),
        ],
      );

  static GridTemplate _eight() => GridTemplate(
        id: 'smart_8',
        name: '8 Foto (4x2)',
        cols: 4, rows: 2,
        cells: [
          c(0, 0, 0.25, 0.5), c(0.25, 0, 0.25, 0.5),
          c(0.5, 0, 0.25, 0.5), c(0.75, 0, 0.25, 0.5),
          c(0, 0.5, 0.25, 0.5), c(0.25, 0.5, 0.25, 0.5),
          c(0.5, 0.5, 0.25, 0.5), c(0.75, 0.5, 0.25, 0.5),
        ],
      );

  static GridTemplate _nine() => GridTemplate(
        id: 'smart_9',
        name: '9 Foto (3x3)',
        cols: 3, rows: 3,
        cells: List.generate(9, (i) => c(
          (i % 3) * 0.333,
          (i ~/ 3) * 0.333,
          0.334, 0.334,
        )),
      );

  static GridTemplate _ten() => GridTemplate(
        id: 'smart_10',
        name: '10 Foto',
        cols: 4, rows: 3,
        cells: [
          // row 1: 3 cells
          c(0, 0, 0.333, 0.333), c(0.333, 0, 0.334, 0.333), c(0.666, 0, 0.334, 0.333),
          // row 2: 4 cells
          c(0, 0.333, 0.25, 0.334), c(0.25, 0.333, 0.25, 0.334),
          c(0.5, 0.333, 0.25, 0.334), c(0.75, 0.333, 0.25, 0.334),
          // row 3: 3 cells
          c(0, 0.667, 0.333, 0.333), c(0.333, 0.667, 0.334, 0.333), c(0.666, 0.667, 0.334, 0.333),
        ],
      );

  static GridTemplate _eleven() => GridTemplate(
        id: 'smart_11',
        name: '11 Foto',
        cols: 4, rows: 3,
        cells: [
          c(0, 0, 0.25, 0.333), c(0.25, 0, 0.25, 0.333),
          c(0.5, 0, 0.25, 0.333), c(0.75, 0, 0.25, 0.333),
          c(0, 0.333, 0.25, 0.334), c(0.25, 0.333, 0.25, 0.334),
          c(0.5, 0.333, 0.25, 0.334), c(0.75, 0.333, 0.25, 0.334),
          c(0, 0.667, 0.333, 0.333), c(0.333, 0.667, 0.334, 0.333), c(0.666, 0.667, 0.334, 0.333),
        ],
      );

  static GridTemplate _twelve() => GridTemplate(
        id: 'smart_12',
        name: '12 Foto (4x3)',
        cols: 4, rows: 3,
        cells: List.generate(12, (i) => c(
          (i % 4) * 0.25,
          (i ~/ 4) * 0.334,
          0.25, 0.334,
        )),
      );
}
