import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../models/grid_template.dart';
import '../models/grid_project.dart';

class GridPreview extends StatefulWidget {
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

  @override
  State<GridPreview> createState() => _GridPreviewState();
}

class _GridPreviewState extends State<GridPreview> {
  // Local state untuk drag — biar real-time tanpa rebuild parent
  final Map<int, Offset> _dragPositions = {};
  int? _draggingIndex;

  Widget _buildBackground() {
    switch (widget.backgroundType) {
      case BackgroundType.solid:
        return Container(color: widget.backgroundColor);

      case BackgroundType.gradient:
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.backgroundColor,
                widget.gradientEndColor ?? widget.backgroundColor.withOpacity(0.5),
              ],
            ),
          ),
        );

      case BackgroundType.blurredImage:
        final firstImage = widget.imagePaths.firstWhere(
          (p) => p != null,
          orElse: () => null,
        );
        if (firstImage == null) {
          return Container(color: widget.backgroundColor);
        }
        return Stack(
          fit: StackFit.expand,
          children: [
            Image.file(
              File(firstImage),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: widget.backgroundColor),
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
        return Text(o.content,
            style: TextStyle(fontSize: o.fontSize * o.scale));
    }
  }

  Widget _buildTransformedImage(String path, int index) {
    final t = (widget.transforms != null && index < widget.transforms!.length)
        ? widget.transforms![index]
        : CellTransform();

    Widget img = Image.file(
      File(path),
      fit: BoxFit.cover,
      gaplessPlayback: true,
      errorBuilder: (_, __, ___) => Container(color: widget.cellColor),
    );

    if (t.flipH || t.flipV) {
      img = Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..scale(t.flipH ? -1.0 : 1.0, t.flipV ? -1.0 : 1.0, 1.0),
        child: img,
      );
    }

    if (t.zoom != 1.0) {
      img = Transform.scale(scale: t.zoom, child: img);
    }

    if (t.rotation != 0.0) {
      img = Transform.rotate(angle: t.rotation, child: img);
    }

    if (t.offset != Offset.zero) {
      img = FractionalTranslation(translation: t.offset, child: img);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.cornerRadius),
      child: img,
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = AspectRatio(
      aspectRatio: widget.ratio.value,
      child: Stack(
        children: [
          Positioned.fill(child: _buildBackground()),

          // Grid cells
          LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final h = constraints.maxHeight;

              return Stack(
                children: widget.template.cells.asMap().entries.map((entry) {
                  final i = entry.key;
                  final cell = entry.value;
                  final path = i < widget.imagePaths.length
                      ? widget.imagePaths[i]
                      : null;

                  return Positioned(
                    left: cell.x * w + widget.borderWidth / 2,
                    top: cell.y * h + widget.borderWidth / 2,
                    width: cell.w * w - widget.borderWidth,
                    height: cell.h * h - widget.borderWidth,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(widget.cornerRadius),
                      child: Container(
                        decoration: BoxDecoration(
                          color: path == null ? widget.cellColor : null,
                          borderRadius: BorderRadius.circular(widget.cornerRadius),
                          border: widget.borderWidth > 0
                              ? Border.all(
                                  color: widget.borderColor,
                                  width: widget.borderWidth)
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

          // Overlay layer (drag real-time via local state)
          if (widget.overlays != null && widget.overlays!.isNotEmpty)
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth;
                  final h = constraints.maxHeight;
                  return Stack(
                    children:
                        widget.overlays!.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final o = entry.value;

                      // Gunakan drag local position kalau sedang drag
                      final pos = _dragPositions[idx] ?? o.position;

                      return Positioned(
                        left: pos.dx * w - 50 * o.scale,
                        top: pos.dy * h - 25 * o.scale,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: widget.onOverlayTap != null
                              ? () => widget.onOverlayTap!(idx)
                              : null,
                          onPanStart: (_) {
                            setState(() => _draggingIndex = idx);
                          },
                          onPanUpdate: (details) {
                            setState(() {
                              final newPos = Offset(
                                ((_dragPositions[idx]?.dx ?? o.position.dx) +
                                        details.delta.dx / w)
                                    .clamp(0.0, 1.0),
                                ((_dragPositions[idx]?.dy ?? o.position.dy) +
                                        details.delta.dy / h)
                                    .clamp(0.0, 1.0),
                              );
                              _dragPositions[idx] = newPos;
                            });
                          },
                          onPanEnd: (_) {
                            final finalPos = _dragPositions[idx];
                            if (finalPos != null &&
                                widget.onOverlayMove != null) {
                              widget.onOverlayMove!(idx, finalPos);
                            }
                            setState(() {
                              _dragPositions.remove(idx);
                              _draggingIndex = null;
                            });
                          },
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
    );

    if (widget.fixedHeight != null) {
      return SizedBox(height: widget.fixedHeight, child: content);
    }
    return content;
  }
}
