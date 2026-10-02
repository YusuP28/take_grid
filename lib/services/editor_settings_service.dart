import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditorSettingsService {
  static final EditorSettingsService _i = EditorSettingsService._();
  factory EditorSettingsService() => _i;
  EditorSettingsService._();

  static const _kBorderWidth = 'default_border_width';
  static const _kBorderColor = 'default_border_color';
  static const _kCornerRadius = 'default_corner_radius';
  static const _kBgColor = 'default_bg_color';
  static const _kBgType = 'default_bg_type';
  static const _kRatio = 'default_ratio';
  static const _kGradientEnd = 'default_gradient_end';

  // Cache
  double? _borderWidth;
  Color? _borderColor;
  double? _cornerRadius;
  Color? _bgColor;
  Color? _gradientEnd;
  int? _bgTypeIndex;
  int? _ratioIndex;

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    _borderWidth = p.getDouble(_kBorderWidth);
    _borderColor = _colorFromInt(p.getInt(_kBorderColor));
    _cornerRadius = p.getDouble(_kCornerRadius);
    _bgColor = _colorFromInt(p.getInt(_kBgColor));
    _gradientEnd = _colorFromInt(p.getInt(_kGradientEnd));
    _bgTypeIndex = p.getInt(_kBgType);
    _ratioIndex = p.getInt(_kRatio);
  }

  Future<void> saveBorderWidth(double v) async {
    _borderWidth = v;
    final p = await SharedPreferences.getInstance();
    await p.setDouble(_kBorderWidth, v);
  }

  Future<void> saveBorderColor(Color c) async {
    _borderColor = c;
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kBorderColor, c.value);
  }

  Future<void> saveCornerRadius(double v) async {
    _cornerRadius = v;
    final p = await SharedPreferences.getInstance();
    await p.setDouble(_kCornerRadius, v);
  }

  Future<void> saveBgColor(Color c) async {
    _bgColor = c;
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kBgColor, c.value);
  }

  Future<void> saveGradientEnd(Color c) async {
    _gradientEnd = c;
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kGradientEnd, c.value);
  }

  Future<void> saveBgType(int idx) async {
    _bgTypeIndex = idx;
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kBgType, idx);
  }

  Future<void> saveRatio(int idx) async {
    _ratioIndex = idx;
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kRatio, idx);
  }

  // Getters
  double? get borderWidth => _borderWidth;
  Color? get borderColor => _borderColor;
  double? get cornerRadius => _cornerRadius;
  Color? get bgColor => _bgColor;
  Color? get gradientEnd => _gradientEnd;
  int? get bgTypeIndex => _bgTypeIndex;
  int? get ratioIndex => _ratioIndex;

  Color? _colorFromInt(int? v) => v == null ? null : Color(v);
}
