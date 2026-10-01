import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../models/grid_template.dart';
import '../models/grid_project.dart';

class GridPreview extends StatelessWidget {
  final GridTemplate template;
  final List<String?> imagePaths;
  final double borderWidth;
  final Color borderColor;
  final Color backgroundColor;
  final Color? gradientEndColor;
  final BackgroundType backgroundType;
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
    this.gradientEndColor,
    this.backgroundType = BackgroundType.solid,
    this.cellColor = const Color(0xFFE0E0E0),
    this.ratio = GridRatio.square,
    this.fixedHeight,
    this.cornerRadius = 0,
  });

  Widget _buildBackground() {
    switch (backgroundType) {
      case BackgroundType.solid:
        return Container(color: backgroundColor);

      case BackgroundType.gradient:
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                backgroundColor,
                gradientEndColor ?? backgroundColor.withOpacity(0.5),
              ],
            ),
          ),
        );

      case BackgroundType.blurredImage:
        // Ambil foto pertama, blur
        final firstImage = imagePaths.firstWhere(
          (p) => p != null,
          orElse: () => null,
        );
        if (firstImage == null) {
          return Container(color: backgroundColor);
        }
        return Stack(
          fit: StackFit.expand,
          children: [
            Image.file(
              File(firstImage),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: backgroundColor),
            ),
            BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(color: Colors.white.withOpacity(0.3)),
            ),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = AspectRatio(
      aspectRatio: ratio.value,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(cornerRadius > 0 ? 0 : 0),
        child: Stack(
          children: [
            // Background layer
            Positioned.fill(child: _buildBackground()),

            // Grid cells
            LayoutBuilder(
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
                                ? Border.all(
                                    color: borderColor, width: borderWidth)
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
          ],
        ),
      ),
    );

    if (fixedHeight != null) {
      return SizedBox(height: fixedHeight, child: content);
    }
    return content;
  }
}
