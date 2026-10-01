import 'dart:io';
import 'package:flutter/material.dart';
import '../models/grid_template.dart';
import '../models/grid_project.dart';

class GridPreview extends StatelessWidget {
  final GridTemplate template;
  final List<String?> imagePaths;
  final double borderWidth;
  final Color borderColor;
  final Color backgroundColor;
  final Color cellColor;
  final GridRatio ratio;
  final double? fixedHeight;
  final double cornerRadius;

  const GridPreview({
    super.key,
    required this.template,
    this.imagePaths = const [],
    this.borderWidth = 2.0,
    this.borderColor = Colors.white,
    this.backgroundColor = Colors.white,
    this.cellColor = const Color(0xFFE0E0E0),
    this.ratio = GridRatio.square,
    this.fixedHeight,
    this.cornerRadius = 0,
  });

  @override
  Widget build(BuildContext context) {
    final content = AspectRatio(
      aspectRatio: ratio.value,
      child: Container(
        color: backgroundColor,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;

            return Stack(
              children: template.cells.asMap().entries.map((entry) {
                final i = entry.key;
                final cell = entry.value;
                final path = i < imagePaths.length ? imagePaths[i] : null;

                return Positioned(
                  left: cell.x * w + borderWidth / 2,
                  top: cell.y * h + borderWidth / 2,
                  width: cell.w * w - borderWidth,
                  height: cell.h * h - borderWidth,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(cornerRadius),
                    child: Container(
                    decoration: BoxDecoration(
                      color: path == null ? cellColor : null,
                      borderRadius: BorderRadius.circular(cornerRadius),
                      border: borderWidth > 0
                          ? Border.all(color: borderColor, width: borderWidth)
                          : null,
                    ),
                    child: path != null
                        ? Image.file(
                            File(path),
                            fit: BoxFit.cover,
                            gaplessPlayback: true,
                            errorBuilder: (_, __, ___) =>
                                Container(color: cellColor),
                          )
                        : null,
                  ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );

    if (fixedHeight != null) {
      return SizedBox(height: fixedHeight, child: content);
    }
    return content;
  }
}
