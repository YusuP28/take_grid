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
  final void Function(int)? onCellTap;
  final void Function(int idx, double zoom, Offset offset)? onCellTransform;
  final void Function(int idx)? onCellTransformEnd;

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
    this.onCellTap,
    this.onCellTransform,
    this.onCellTransformEnd,
  });

  @override
  State<GridPreview> createState() => _GridPreviewState();
}

class _GridPreviewState extends State<GridPreview> {
  // Local state untuk drag — biar real-time tanpa rebuild parent
  final Map<int, Offset> _dragPositions = {};
  int? _draggingIndex;
  final Map<int, double> _scaleStartZoom = {};
  final Map<int, Offset> _scaleStartOffset = {};
  final Map<int, Offset> _liveOffset = {};
  final Map<int, double> _liveZoom = {};

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

    // LayoutBuilder: tahu ukuran cell aktual → hitung overflow
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final cellW = constraints.maxWidth;
        final cellH = constraints.maxHeight;

        // Base image: fit contain dulu supaya aspect diketahui
        Widget baseImg = Image.file(
          File(path),
          fit: BoxFit.contain,
          gaplessPlayback: true,
          errorBuilder: (_, __, ___) => Container(color: widget.cellColor),
        );

        // Flip
        if (t.flipH || t.flipV) {
          baseImg = Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..scale(t.flipH ? -1.0 : 1.0, t.flipV ? -1.0 : 1.0, 1.0),
            child: baseImg,
          );
        }

        // Rotate (kalau ada)
        if (t.rotation != 0.0) {
          baseImg = Transform.rotate(angle: t.rotation, child: baseImg);
        }

        // Color filter
        if (t.hasFilter) {
          baseImg = ColorFiltered(
            colorFilter: ColorFilter.matrix(_buildColorMatrix(t)),
            child: baseImg,
          );
        }

        // Cover cell: pakai FittedBox supaya image cover area cell
        // (skala image sampai cover, bagian luar clip)
        Widget covered = ClipRect(
          child: SizedBox(
            width: cellW,
            height: cellH,
            child: FittedBox(
              fit: BoxFit.cover,
              clipBehavior: Clip.hardEdge,
              child: SizedBox(
                // Placeholder size — aspect dari image akan di-respect oleh FittedBox
                width: cellW,
                height: cellH,
                child: baseImg,
              ),
            ),
          ),
        );

        // Zoom + pan:
        // - zoom mengalikan skala (1.0 = cover pas)
        // - offset dalam fraction cell (-1..1) → geser pixel = offset * cell
        // Hitung overflow: setelah zoom, berapa pixel ekstra di setiap sisi
        // Bounding: total overflow = (zoom - 1) * cell / 2 per sisi
        // Opsi A: bisa geser walau zoom 1.0 (foto cover punya overflow)
        // Formula: 0.5 cell (base overflow) + tambahan dari zoom
        final maxShiftX = (0.5 + (t.zoom - 1.0) / 2).clamp(0.0, 10.0) * cellW;
        final maxShiftY = (0.5 + (t.zoom - 1.0) / 2).clamp(0.0, 10.0) * cellH;

        // offset disimpan normalized -1..1, di-map ke -maxShift..+maxShift
        final shiftX = t.offset.dx * maxShiftX;
        final shiftY = t.offset.dy * maxShiftY;

        Widget transformed = Transform.scale(
          scale: t.zoom,
          child: Transform.translate(
            offset: Offset(shiftX, shiftY),
            child: covered,
          ),
        );

        return ClipRRect(
          borderRadius: BorderRadius.circular(widget.cornerRadius),
          child: transformed,
        );
      },
    );
  }

  /// Build color matrix dari brightness/contrast/saturation/warmth
  List<double> _buildColorMatrix(CellTransform t) {
    // Brightness: -1..1 → -255..255 offset
    final b = t.brightness * 255;

    // Contrast: 0..2 → standard contrast matrix
    final c = t.contrast;
    final ct = (1.0 - c) * 0.5 * 255;

    // Saturation: 0..2 → mix with luminance
    final sat = t.saturation;
    final sr = (1 - sat) * 0.2126;
    final sg = (1 - sat) * 0.7152;
    final sb = (1 - sat) * 0.0722;

    // Warmth: -1..1 → orange/blue shift
    final w = t.warmth;
    final wr = 1.0 + w * 0.3;
    final wb = 1.0 - w * 0.3;

    // Kombinasi: contrast × saturation × warmth, lalu tambah brightness
    final r0 = (sr + sat * wr) * c;
    final r1 = sg * c;
    final r2 = sb * c;
    final g0 = sr * c;
    final g1 = (sg + sat) * c;
    final g2 = sb * c;
    final b0 = sr * c;
    final b1 = sg * c;
    final b2 = (sb + sat * wb) * c;

    return <double>[
      r0, r1, r2, 0, b + ct,
      g0, g1, g2, 0, b + ct,
      b0, b1, b2, 0, b + ct,
      0, 0, 0, 1, 0,
    ];
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
                    child: GestureDetector(
                      onTap: widget.onCellTap != null ? () => widget.onCellTap!(i) : null,
                      onScaleStart: widget.onCellTransform != null
                          ? (_) {
                              final t = (widget.transforms != null && i < widget.transforms!.length)
                                  ? widget.transforms![i]
                                  : null;
                              if (t != null) {
                                _scaleStartZoom[i] = t.zoom;
                                _scaleStartOffset[i] = t.offset;
                                _liveZoom[i] = t.zoom;
                                _liveOffset[i] = t.offset;
                              }
                            }
                          : null,
                      onScaleUpdate: widget.onCellTransform != null
                          ? (details) {
                              final t = (widget.transforms != null && i < widget.transforms!.length)
                                  ? widget.transforms![i]
                                  : null;
                              if (t == null) return;
                              final baseZoom = _scaleStartZoom[i] ?? t.zoom;
                              final cw = cell.w * w;
                              final ch = cell.h * h;
                              if (cw <= 0 || ch <= 0) return;

                              // Zoom: relatif ke baseline
                              final newZoom = (baseZoom * details.scale).clamp(1.0, 5.0);

                              // Pan: akumulatif dari live state (bukan baseOff)
                              final liveOff = _liveOffset[i] ?? _scaleStartOffset[i] ?? t.offset;
                              // Clamp diperluas supaya user bisa geser
                              // seluruh area foto di luar cell (untuk crop)
                              final maxOffX = ((t.zoom > 1.0) ? t.zoom : 1.0);
                              final maxOffY = ((t.zoom > 1.0) ? t.zoom : 1.0);
                              final newOffset = Offset(
                                (liveOff.dx + details.focalPointDelta.dx / cw).clamp(-maxOffX, maxOffX),
                                (liveOff.dy + details.focalPointDelta.dy / ch).clamp(-maxOffY, maxOffY),
                              );
                              _liveOffset[i] = newOffset;
                              _liveZoom[i] = newZoom;

                              widget.onCellTransform!(i, newZoom, newOffset);
                            }
                          : null,
                      onScaleEnd: widget.onCellTransformEnd != null
                          ? (_) {
                              _scaleStartZoom.remove(i);
                              _scaleStartOffset.remove(i);
                              _liveZoom.remove(i);
                              _liveOffset.remove(i);
                              widget.onCellTransformEnd!(i);
                            }
                          : null,
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
