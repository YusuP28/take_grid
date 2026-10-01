import 'package:flutter/material.dart';

enum FreeStyleType { image, text, sticker }

class FreeStyleItem {
  final String id;
  FreeStyleType type;
  String content; // path / text
  Offset position; // 0..1
  double scale;
  double rotation;

  FreeStyleItem({
    required this.id,
    required this.type,
    required this.content,
    this.position = const Offset(0.5, 0.5),
    this.scale = 0.4,
    this.rotation = 0.0,
  });
}
