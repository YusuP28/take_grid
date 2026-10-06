import 'dart:ui';
import 'package:flutter/material.dart';
import 'grid_template.dart';

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

enum OverlayType { text, sticker, emoji }

class OverlayItem {
  final String id;
  OverlayType type;
  String content;
  Offset position;
  double scale;
  double rotation;
  Color color;
  double fontSize;

  OverlayItem({
    required this.id,
    required this.type,
    required this.content,
    this.position = const Offset(0.5, 0.5),
    this.scale = 1.0,
    this.rotation = 0.0,
    this.color = Colors.white,
    this.fontSize = 24,
  });

  OverlayItem copyWith({
    String? content,
    Offset? position,
    double? scale,
    double? rotation,
    Color? color,
    double? fontSize,
  }) => OverlayItem(
        id: id,
        type: type,
        content: content ?? this.content,
        position: position ?? this.position,
        scale: scale ?? this.scale,
        rotation: rotation ?? this.rotation,
        color: color ?? this.color,
        fontSize: fontSize ?? this.fontSize,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'content': content,
        'dx': position.dx,
        'dy': position.dy,
        'scale': scale,
        'rotation': rotation,
        'color': color.value,
        'fontSize': fontSize,
      };

  factory OverlayItem.fromJson(Map<String, dynamic> j) => OverlayItem(
        id: j['id'] as String,
        type: OverlayType.values.firstWhere((e) => e.name == j['type']),
        content: j['content'] as String,
        position: Offset((j['dx'] as num).toDouble(), (j['dy'] as num).toDouble()),
        scale: (j['scale'] as num).toDouble(),
        rotation: (j['rotation'] as num).toDouble(),
        color: Color(j['color'] as int),
        fontSize: (j['fontSize'] as num).toDouble(),
      );
}

class CellTransform {
  double zoom;
  double rotation;
  bool flipH;
  bool flipV;
  Offset offset;
  // Filters
  double brightness; // -1.0 to 1.0
  double contrast;   // 0.0 to 2.0
  double saturation; // 0.0 to 2.0
  double warmth;     // -1.0 to 1.0 (blue to orange)

  CellTransform({
    this.zoom = 1.0,
    this.rotation = 0.0,
    this.flipH = false,
    this.flipV = false,
    this.offset = Offset.zero,
    this.brightness = 0.0,
    this.contrast = 1.0,
    this.saturation = 1.0,
    this.warmth = 0.0,
  });

  CellTransform copyWith({
    double? zoom,
    double? rotation,
    bool? flipH,
    bool? flipV,
    Offset? offset,
    double? brightness,
    double? contrast,
    double? saturation,
    double? warmth,
  }) => CellTransform(
        zoom: zoom ?? this.zoom,
        rotation: rotation ?? this.rotation,
        flipH: flipH ?? this.flipH,
        flipV: flipV ?? this.flipV,
        offset: offset ?? this.offset,
        brightness: brightness ?? this.brightness,
        contrast: contrast ?? this.contrast,
        saturation: saturation ?? this.saturation,
        warmth: warmth ?? this.warmth,
      );

  bool get hasFilter =>
      brightness != 0.0 ||
      contrast != 1.0 ||
      saturation != 1.0 ||
      warmth != 0.0;

  void reset() {
    zoom = 1.0;
    rotation = 0.0;
    flipH = false;
    flipV = false;
    offset = Offset.zero;
    brightness = 0.0;
    contrast = 1.0;
    saturation = 1.0;
    warmth = 0.0;
  }

  void resetFilter() {
    brightness = 0.0;
    contrast = 1.0;
    saturation = 1.0;
    warmth = 0.0;
  }

  Map<String, dynamic> toJson() => {
        'zoom': zoom,
        'rotation': rotation,
        'flipH': flipH,
        'flipV': flipV,
        'dx': offset.dx,
        'dy': offset.dy,
        'brightness': brightness,
        'contrast': contrast,
        'saturation': saturation,
        'warmth': warmth,
      };

  factory CellTransform.fromJson(Map<String, dynamic> j) => CellTransform(
        zoom: (j['zoom'] as num).toDouble(),
        rotation: (j['rotation'] as num).toDouble(),
        flipH: j['flipH'] as bool,
        flipV: j['flipV'] as bool,
        offset: Offset((j['dx'] as num).toDouble(), (j['dy'] as num).toDouble()),
        brightness: (j['brightness'] as num).toDouble(),
        contrast: (j['contrast'] as num).toDouble(),
        saturation: (j['saturation'] as num).toDouble(),
        warmth: (j['warmth'] as num).toDouble(),
      );
}

class GridProject {
  GridTemplate template;
  List<String?> imagePaths;
  double borderWidth;
  Color borderColor;
  Color backgroundColor;
  Color? gradientEndColor;
  BackgroundType backgroundType;
  GridRatio ratio;
  double cornerRadius;
  List<CellTransform> transforms;
  List<OverlayItem> overlays;

  GridProject({
    required this.template,
    List<String?>? imagePaths,
    this.borderWidth = 4.0,
    this.borderColor = Colors.white,
    this.backgroundColor = Colors.white,
    this.gradientEndColor,
    this.backgroundType = BackgroundType.solid,
    List<CellTransform>? transforms,
    List<OverlayItem>? overlays,
    this.ratio = GridRatio.square,
    this.cornerRadius = 0,
  })  : imagePaths = imagePaths ?? List.filled(template.cellCount, null),
        transforms =
            transforms ?? List.generate(template.cellCount, (_) => CellTransform()),
        overlays = overlays ?? [];

  bool get isComplete =>
      imagePaths.where((p) => p != null).length == template.cellCount;

  int get filledCount => imagePaths.where((p) => p != null).length;

  void setImage(int index, String? path) {
    if (index >= 0 && index < imagePaths.length) {
      imagePaths[index] = path;
    }
  }

  Map<String, dynamic> toJson() => {
        'templateId': template.id,
        'imagePaths': imagePaths,
        'borderWidth': borderWidth,
        'borderColor': borderColor.value,
        'backgroundColor': backgroundColor.value,
        'gradientEndColor': gradientEndColor?.value,
        'backgroundType': backgroundType.name,
        'ratio': ratio.name,
        'cornerRadius': cornerRadius,
        'transforms': transforms.map((t) => t.toJson()).toList(),
        'overlays': overlays.map((o) => o.toJson()).toList(),
      };

  factory GridProject.fromJson(
    Map<String, dynamic> j,
    GridTemplate template,
  ) {
    return GridProject(
      template: template,
      imagePaths: (j['imagePaths'] as List).cast<String?>(),
      borderWidth: (j['borderWidth'] as num).toDouble(),
      borderColor: Color(j['borderColor'] as int),
      backgroundColor: Color(j['backgroundColor'] as int),
      gradientEndColor: j['gradientEndColor'] == null
          ? null
          : Color(j['gradientEndColor'] as int),
      backgroundType: BackgroundType.values
          .firstWhere((e) => e.name == j['backgroundType']),
      ratio: GridRatio.values.firstWhere((e) => e.name == j['ratio']),
      cornerRadius: (j['cornerRadius'] as num).toDouble(),
      transforms: (j['transforms'] as List)
          .map((e) => CellTransform.fromJson(e as Map<String, dynamic>))
          .toList(),
      overlays: (j['overlays'] as List)
          .map((e) => OverlayItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
