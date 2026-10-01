import 'package:flutter/material.dart';

/// Satu cell dalam template grid
class GridCell {
  final double x; // 0.0 - 1.0 (relatif)
  final double y;
  final double w;
  final double h;

  const GridCell({
    required this.x,
    required this.y,
    required this.w,
    required this.h,
  });
}

/// Template grid
class GridTemplate {
  final String id;
  final String name;
  final int cols;
  final int rows;
  final List<GridCell> cells;
  final IconData icon;

  const GridTemplate({
    required this.id,
    required this.name,
    required this.cols,
    required this.rows,
    required this.cells,
    this.icon = Icons.grid_on,
  });

  int get cellCount => cells.length;
}

/// Preset template
class GridTemplates {
  static final List<GridTemplate> all = [
    _t2x2(),
    _t3x3(),
    _t2x1(),
    _t1x2(),
    _t3x1(),
    _t1x3(),
    _t2x2withBigLeft(),
    _t3x3withBigCenter(),
  ];

  static GridTemplate _t2x2() => const GridTemplate(
        id: 'grid_2x2',
        name: '2×2',
        cols: 2,
        rows: 2,
        icon: Icons.grid_view,
        cells: [
          GridCell(x: 0, y: 0, w: 0.5, h: 0.5),
          GridCell(x: 0.5, y: 0, w: 0.5, h: 0.5),
          GridCell(x: 0, y: 0.5, w: 0.5, h: 0.5),
          GridCell(x: 0.5, y: 0.5, w: 0.5, h: 0.5),
        ],
      );

  static GridTemplate _t3x3() => const GridTemplate(
        id: 'grid_3x3',
        name: '3×3',
        cols: 3,
        rows: 3,
        icon: Icons.grid_on,
        cells: [
          GridCell(x: 0, y: 0, w: 0.333, h: 0.333),
          GridCell(x: 0.333, y: 0, w: 0.333, h: 0.333),
          GridCell(x: 0.666, y: 0, w: 0.334, h: 0.333),
          GridCell(x: 0, y: 0.333, w: 0.333, h: 0.333),
          GridCell(x: 0.333, y: 0.333, w: 0.333, h: 0.333),
          GridCell(x: 0.666, y: 0.333, w: 0.334, h: 0.333),
          GridCell(x: 0, y: 0.666, w: 0.333, h: 0.334),
          GridCell(x: 0.333, y: 0.666, w: 0.333, h: 0.334),
          GridCell(x: 0.666, y: 0.666, w: 0.334, h: 0.334),
        ],
      );

  static GridTemplate _t2x1() => const GridTemplate(
        id: 'grid_2x1',
        name: '2×1',
        cols: 2,
        rows: 1,
        cells: [
          GridCell(x: 0, y: 0, w: 0.5, h: 1),
          GridCell(x: 0.5, y: 0, w: 0.5, h: 1),
        ],
      );

  static GridTemplate _t1x2() => const GridTemplate(
        id: 'grid_1x2',
        name: '1×2',
        cols: 1,
        rows: 2,
        cells: [
          GridCell(x: 0, y: 0, w: 1, h: 0.5),
          GridCell(x: 0, y: 0.5, w: 1, h: 0.5),
        ],
      );

  static GridTemplate _t3x1() => const GridTemplate(
        id: 'grid_3x1',
        name: '3×1',
        cols: 3,
        rows: 1,
        cells: [
          GridCell(x: 0, y: 0, w: 0.333, h: 1),
          GridCell(x: 0.333, y: 0, w: 0.333, h: 1),
          GridCell(x: 0.666, y: 0, w: 0.334, h: 1),
        ],
      );

  static GridTemplate _t1x3() => const GridTemplate(
        id: 'grid_1x3',
        name: '1×3',
        cols: 1,
        rows: 3,
        cells: [
          GridCell(x: 0, y: 0, w: 1, h: 0.333),
          GridCell(x: 0, y: 0.333, w: 1, h: 0.333),
          GridCell(x: 0, y: 0.666, w: 1, h: 0.334),
        ],
      );

  static GridTemplate _t2x2withBigLeft() => const GridTemplate(
        id: 'grid_2x2_bigleft',
        name: '2×2 Big Left',
        cols: 2,
        rows: 2,
        cells: [
          GridCell(x: 0, y: 0, w: 0.5, h: 1),
          GridCell(x: 0.5, y: 0, w: 0.5, h: 0.5),
          GridCell(x: 0.5, y: 0.5, w: 0.5, h: 0.5),
        ],
      );

  static GridTemplate _t3x3withBigCenter() => const GridTemplate(
        id: 'grid_3x3_bigcenter',
        name: '3×3 Big Center',
        cols: 3,
        rows: 3,
        cells: [
          GridCell(x: 0, y: 0, w: 0.333, h: 0.333),
          GridCell(x: 0.333, y: 0, w: 0.334, h: 0.333),
          GridCell(x: 0.666, y: 0, w: 0.334, h: 0.333),
          GridCell(x: 0, y: 0.333, w: 0.333, h: 0.667),
          GridCell(x: 0.333, y: 0.333, w: 0.334, h: 0.667),
          GridCell(x: 0.666, y: 0.333, w: 0.334, h: 0.667),
        ],
      );
}
