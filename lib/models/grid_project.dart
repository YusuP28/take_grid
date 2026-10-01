import 'package:flutter/material.dart';
import 'grid_template.dart';

enum GridRatio {
  square('1:1', 1.0),
  portrait34('3:4', 3 / 4),
  landscape43('4:3', 4 / 3),
  portrait45('4:5', 4 / 5),
  landscape54('5:4', 5 / 4),
  portrait916('9:16', 9 / 16),
  landscape169('16:9', 16 / 9);

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
  GridRatio ratio;

  GridProject({
    required this.template,
    List<String?>? imagePaths,
    this.borderWidth = 4.0,
    this.borderColor = Colors.white,
    this.backgroundColor = Colors.white,
    this.ratio = GridRatio.square,
  }) : imagePaths = imagePaths ?? List.filled(template.cellCount, null);

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
  }) {
    return GridProject(
      template: template ?? this.template,
      imagePaths: imagePaths ?? List.from(this.imagePaths),
      borderWidth: borderWidth ?? this.borderWidth,
      borderColor: borderColor ?? this.borderColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      ratio: ratio ?? this.ratio,
    );
  }
}
