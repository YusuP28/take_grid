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
  final List<CellTransform>? transforms;
  final List<OverlayItem>? overlays;
  final void Function(int, Offset)? onOverlayMove;
  final void Function(int)? onOverlayTap;

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
    this.transforms,
    this.overlays,
    this.onOverlayMove,
    this.onOverlayTap,
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

  Widget _buildOverlay(OverlayItem o) {
    switch (o.type) {
      case OverlayType.emoji:
        return Text(o.content,
            style: TextStyle(fontSize: o.fontSize * o.scale));
      case OverlayType.text:
        return Container(
          constraints: const BoxConstraints(maxWidth: 200),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            o.content,
            style: TextStyle(
              fontSize: o.fontSize * o.scale,
              color: o.color,
              fontWeight: FontWeight.bold,
              shadows: const [
                Shadow(offset: Offset(1, 1), blurRadius: 2, color: Colors.black54),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        );
      case OverlayType.sticker:
        // Placeholder — bisa diperluas dengan asset
        return Text(o.content,
            style: TextStyle(fontSize: o.fontSize * o.scale));
    }
  }

  Widget _buildTransformedImage(String path, int index) {
    final t = (transforms != null && index < transforms!.length)
        ? transforms![index]
        : CellTransform();

    Widget img = Image.file(
      File(path),
      fit: BoxFit.cover,
      gaplessPlayback: true,
      errorBuilder: (_, __, ___) => Container(color: cellColor),
    );

    // Flip
    if (t.flipH || t.flipV) {
      img = Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..scale(t.flipH ? -1.0 : 1.0, t.flipV ? -1.0 : 1.0, 1.0),
        child: img,
      );
    }

    // Zoom
    if (t.zoom != 1.0) {
      img = Transform.scale(scale: t.zoom, child: img);
    }

    // Rotation
    if (t.rotation != 0.0) {
      img = Transform.rotate(angle: t.rotation, child: img);
    }

    // Offset (pan)
    if (t.offset != Offset.zero) {
      img = FractionalTranslation(translation: t.offset, child: img);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(cornerRadius),
      child: img,
    );
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
                              ? _buildTransformedImage(path, i)
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),

            // Overlay layer (drag-able)
            if (overlays != null && overlays!.isNotEmpty)
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final w = constraints.maxWidth;
                    final h = constraints.maxHeight;
                    return Stack(
                      children: overlays!.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final o = entry.value;
                        return Positioned(
                          left: o.position.dx * w - 50 * o.scale,
                          top: o.position.dy * h - 25 * o.scale,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: onOverlayTap != null
                                ? () => onOverlayTap!(idx)
                                : null,
                            onPanUpdate: onOverlayMove != null
                                ? (details) {
                                    final dx = details.delta.dx / w;
                                    final dy = details.delta.dy / h;
                                    onOverlayMove!(
                                      idx,
                                      Offset(
                                        (o.position.dx + dx).clamp(0.0, 1.0),
                                        (o.position.dy + dy).clamp(0.0, 1.0),
                                      ),
                                    );
                                  }
                                : null,
                            child: Transform.rotate(
                              angle: o.rotation,
                              child: _buildOverlay(o),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
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
