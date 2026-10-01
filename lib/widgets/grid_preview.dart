import 'package:flutter/material.dart';
import '../models/grid_template.dart';

/// Widget render template grid (kosong / dengan gambar)
class GridPreview extends StatelessWidget {
  final GridTemplate template;
  final List<String> imagePaths; // optional, bisa kosong
  final double borderWidth;
  final Color borderColor;
  final Color backgroundColor;
  final Color cellColor;

  const GridPreview({
    super.key,
    required this.template,
    this.imagePaths = const [],
    this.borderWidth = 2.0,
    this.borderColor = Colors.white,
    this.backgroundColor = Colors.white,
    this.cellColor = const Color(0xFFE0E0E0),
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
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
                final hasImage = i < imagePaths.length;

                return Positioned(
                  left: cell.x * w + borderWidth / 2,
                  top: cell.y * h + borderWidth / 2,
                  width: cell.w * w - borderWidth,
                  height: cell.h * h - borderWidth,
                  child: Container(
                    decoration: BoxDecoration(
                      color: hasImage ? null : cellColor,
                      border: borderWidth > 0
                          ? Border.all(color: borderColor, width: borderWidth)
                          : null,
                    ),
                    child: hasImage
                        ? Image.asset(
                            imagePaths[i],
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(color: cellColor),
                          )
                        : null,
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}
