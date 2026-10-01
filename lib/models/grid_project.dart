import 'dart:ui';
import 'package:flutter/material.dart';
import 'grid_template.dart';

class CellTransform {
  double zoom; // 1.0 = normal, >1 = zoom in
  double rotation; // radians
  bool flipH;
  bool flipV;
  Offset offset; // pan offset dalam persen (-0.5..0.5)

  CellTransform({
    this.zoom = 1.0,
    this.rotation = 0.0,
    this.flipH = false,
    this.flipV = false,
    this.offset = Offset.zero,
  });

  CellTransform copyWith({
    double? zoom,
    double? rotation,
    bool? flipH,
    bool? flipV,
    Offset? offset,
  }) => CellTransform(
        zoom: zoom ?? this.zoom,
        rotation: rotation ?? this.rotation,
        flipH: flipH ?? this.flipH,
        flipV: flipV ?? this.flipV,
        offset: offset ?? this.offset,
      );

  void reset() {
    zoom = 1.0;
    rotation = 0.0;
    flipH = false;
    flipV = false;
    offset = Offset.zero;
  }
}

enum BackgroundType {
  solid('Warna Solid'),
  gradient('Gradasi'),
  blurredImage('Blur Foto');

  final String label;
  const BackgroundType(this.label);
}

enum GridRatio {
  square('1:1', 1.0),
  portrait34('3:4', 3 / 4),
  landscape43('4:3', 4 / 3),
  portrait45('4:5', 4 / 5),
  landscape54('5:4', 5 / 4),
  portrait916('9:16', 9 / 16),
  landscape169('16:9', 16 / 9),
  portrait23('2:3', 2 / 3),
  landscape32('3:2', 3 / 2),
  story('Story 9:16', 9 / 16),
  post('Post 4:5', 4 / 5);

  final String label;
  final double value;
  const GridRatio(this.label, this.value);
}

class GridProject {
  GridTemplate template;
  List<String?> imagePaths; // per cell, null kalau belum dipilih
  double borderWidth;
  Color borderColor;
  Color backgroundColor;
  Color? gradientEndColor;
  BackgroundType backgroundType;
  List<CellTransform> transforms;
  GridRatio ratio;
  double cornerRadius;

  GridProject({
    required this.template,
    List<String?>? imagePaths,
    this.borderWidth = 4.0,
    this.borderColor = Colors.white,
    this.backgroundColor = Colors.white,
    this.gradientEndColor,
    this.backgroundType = BackgroundType.solid,
    List<CellTransform>? transforms,
    this.ratio = GridRatio.square,
    this.cornerRadius = 0,
  })  : imagePaths = imagePaths ?? List.filled(template.cellCount, null),
        transforms = transforms ??
            List.generate(template.cellCount, (_) => CellTransform());

  bool get isComplete =>
      imagePaths.where((p) => p != null).length == template.cellCount;

  int get filledCount => imagePaths.where((p) => p != null).length;

  void setImage(int index, String? path) {
    if (index >= 0 && index < imagePaths.length) {
      imagePaths[index] = path;
    }
  }

  GridProject copyWith({
    GridTemplate? template,
    List<String?>? imagePaths,
    double? borderWidth,
    Color? borderColor,
    Color? backgroundColor,
    GridRatio? ratio,
    double? cornerRadius,
    List<CellTransform>? transforms,
  }) {
    return GridProject(
      template: template ?? this.template,
      imagePaths: imagePaths ?? List.from(this.imagePaths),
      borderWidth: borderWidth ?? this.borderWidth,
      borderColor: borderColor ?? this.borderColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      ratio: ratio ?? this.ratio,
    )
      ..cornerRadius = cornerRadius ?? this.cornerRadius
      ..transforms = transforms ?? List.from(this.transforms);
  }
}
