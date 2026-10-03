import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

import '../../models/grid_project.dart';
import '../../models/grid_template.dart';
import '../../widgets/grid_preview.dart';
import '../../services/export_service.dart';
import '../../services/editor_settings_service.dart';
import '../../services/smart_grid_service.dart';

enum BottomPanel { none, border, corner, background, text, emoji, transform, filter }

class EditorScreen extends StatefulWidget {
  final GridTemplate template;
  final List<String>? initialImages;
  final GridRatio? initialRatio;
  const EditorScreen({
    super.key,
    required this.template,
    this.initialImages,
    this.initialRatio,
  });

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late GridProject _project;
  final _picker = ImagePicker();
  final _exportKey = GlobalKey();
  ExportFormat _format = ExportFormat.jpg;
  ExportQuality _quality = ExportQuality.fhd1080;
  bool _exporting = false;
  BottomPanel _panel = BottomPanel.none;
  int? _activeCellIndex;
  Color _newTextColor = Colors.white;
  double _newTextSize = 24;
  final _newTextCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _project = GridProject(template: widget.template);
    if (widget.initialRatio != null) _project.ratio = widget.initialRatio!;
    if (widget.initialImages != null) {
      for (int i = 0; i < widget.initialImages!.length; i++) {
        if (i >= _project.imagePaths.length) break;
        _project.setImage(i, widget.initialImages![i]);
      }
    }
    _loadSavedSettings();
  }

  Future<void> _loadSavedSettings() async {
    final svc = EditorSettingsService();
    await svc.load();
    if (!mounted) return;
    setState(() {
      if (svc.borderWidth != null) _project.borderWidth = svc.borderWidth!;
      if (svc.borderColor != null) _project.borderColor = svc.borderColor!;
      if (svc.cornerRadius != null) _project.cornerRadius = svc.cornerRadius!;
      if (svc.bgColor != null) _project.backgroundColor = svc.bgColor!;
      if (svc.gradientEnd != null) _project.gradientEndColor = svc.gradientEnd!;
      if (svc.bgTypeIndex != null && svc.bgTypeIndex! < BackgroundType.values.length) {
        _project.backgroundType = BackgroundType.values[svc.bgTypeIndex!];
      }
      if (svc.ratioIndex != null && svc.ratioIndex! < GridRatio.values.length) {
        _project.ratio = GridRatio.values[svc.ratioIndex!];
      }
    });
  }

  // ============= PICK IMAGE =============
  Future<void> _pickImageForCell(int index) async {
    try {
      final f = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90, maxWidth: 2048,
      );
      if (f == null) return;
      if (!mounted) return;
      setState(() => _project.setImage(index, f.path));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e')),
        );
      }
    }
  }

  Future<void> _pickMultipleImages() async {
    try {
      final files = await _picker.pickMultiImage(
        imageQuality: 90, maxWidth: 2048,
      );
      if (files.isEmpty) return;
      if (!mounted) return;
      setState(() {
        int idx = 0;
        for (final f in files) {
          if (idx >= _project.template.cellCount) break;
          _project.setImage(idx, f.path);
          idx++;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e')),
        );
      }
    }
  }

  void _clearCell(int index) {
    setState(() => _project.setImage(index, null));
  }

  void _showCellMenu(int index) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Opsi Cell',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Transform'),
              onTap: () {
                Navigator.pop(ctx);
                setState(() {
                  _activeCellIndex = index;
                  _panel = BottomPanel.transform;
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Ganti Foto'),
              onTap: () { Navigator.pop(ctx); _pickImageForCell(index); },
            ),
            ListTile(
              leading: const Icon(Icons.restart_alt),
              title: const Text('Reset Transform'),
              onTap: () {
                Navigator.pop(ctx);
                setState(() => _project.transforms[index].reset());
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline,
                  color: Theme.of(ctx).colorScheme.error),
              title: Text('Hapus Foto',
                  style: TextStyle(color: Theme.of(ctx).colorScheme.error)),
              onTap: () { Navigator.pop(ctx); _clearCell(index); },
            ),
          ],
        ),
      ),
    );
  }

  // ============= OVERLAY =============
  void _addText() {
    _newTextCtrl.clear();
    setState(() => _panel = BottomPanel.text);
  }

  void _commitText() {
    final txt = _newTextCtrl.text.trim();
    if (txt.isEmpty) return;
    setState(() {
      _project.overlays.add(OverlayItem(
        id: const Uuid().v4(),
        type: OverlayType.text,
        content: txt,
        color: _newTextColor,
        fontSize: _newTextSize,
      ));
      _newTextCtrl.clear();
      _panel = BottomPanel.none;
    });
  }

  void _editOverlay(int index) {
    final o = _project.overlays[index];
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: Text('Edit ${o.type.name}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (o.type == OverlayType.text)
                  TextField(
                    controller: TextEditingController(text: o.content),
                    decoration: const InputDecoration(labelText: 'Teks'),
                    onChanged: (v) => setState(() => o.content = v),
                  ),
                const SizedBox(height: 8),
                Row(children: [
                  const Text('Skala'),
                  Expanded(child: Slider(
                    value: o.scale, min: 0.5, max: 3.0, divisions: 25,
                    onChanged: (v) { setLocal(() {}); setState(() => o.scale = v); },
                  )),
                  Text(o.scale.toStringAsFixed(1)),
                ]),
                Row(children: [
                  const Text('Rotasi'),
                  Expanded(child: Slider(
                    value: o.rotation, min: -3.14159, max: 3.14159, divisions: 12,
                    onChanged: (v) { setLocal(() {}); setState(() => o.rotation = v); },
                  )),
                  Text('${(o.rotation * 180 / 3.14159).round()}°'),
                ]),
                Row(children: [
                  const Text('X'),
                  Expanded(child: Slider(
                    value: o.position.dx, min: 0, max: 1,
                    onChanged: (v) {
                      setLocal(() {});
                      setState(() {
                        _project.overlays[index] = o.copyWith(
                          position: Offset(v, o.position.dy));
                      });
                    },
                  )),
                ]),
                Row(children: [
                  const Text('Y'),
                  Expanded(child: Slider(
                    value: o.position.dy, min: 0, max: 1,
                    onChanged: (v) {
                      setLocal(() {});
                      setState(() {
                        _project.overlays[index] = o.copyWith(
                          position: Offset(o.position.dx, v));
                      });
                    },
                  )),
                ]),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() => _project.overlays.removeAt(index));
                Navigator.pop(ctx);
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
            FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
          ],
        ),
      ),
    );
  }

  // ============= EXPORT =============
  Future<void> _shareResult() async {
    try {
      final pngBytes = await ExportService().captureWidget(_exportKey);
      if (pngBytes == null) throw Exception('Gagal capture');
      final file = await ExportService().saveToTempFile(
        pngBytes: pngBytes, format: _format, quality: _quality,
      );
      if (file == null) throw Exception('Gagal simpan temp');
      // ignore: deprecated_member_use
      await Share.shareXFiles([XFile(file.path)], text: 'Take Grid');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Share gagal: $e')),
        );
      }
    }
  }

  Future<void> _showExportDialog() async {
    if (!_project.isComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(
            'Isi semua foto dulu (${_project.filledCount}/${_project.template.cellCount})')),
      );
      return;
    }
    ExportFormat localFormat = _format;
    ExportQuality localQuality = _quality;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text('Export'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Format', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: ChoiceChip(
                    label: const Center(child: Text('JPG')),
                    selected: localFormat == ExportFormat.jpg,
                    onSelected: (_) => setLocal(() => localFormat = ExportFormat.jpg),
                  )),
                  const SizedBox(width: 8),
                  Expanded(child: ChoiceChip(
                    label: const Center(child: Text('PNG')),
                    selected: localFormat == ExportFormat.png,
                    onSelected: (_) => setLocal(() => localFormat = ExportFormat.png),
                  )),
                ]),
                const SizedBox(height: 16),
                const Text('Kualitas', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...ExportQuality.values.map((q) => RadioListTile<ExportQuality>(
                  dense: true, contentPadding: EdgeInsets.zero,
                  title: Text('${q.label} (${q.px}px)'),
                  value: q, groupValue: localQuality,
                  onChanged: (v) {
                    if (v != null) setLocal(() => localQuality = v);
                  },
                )),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            FilledButton.icon(
              onPressed: () {
                _format = localFormat;
                _quality = localQuality;
                Navigator.pop(ctx);
                _doExport();
              },
              icon: const Icon(Icons.save_alt),
              label: const Text('Export'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _doExport() async {
    setState(() => _exporting = true);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => WillPopScope(
        onWillPop: () async => false,
        child: Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Export sedang diproses...'),
                  SizedBox(height: 8),
                  Text('Mohon tunggu, jangan tutup app',
                      style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    try {
      final has = await ExportService().hasGalleryAccess();
      if (!has) await ExportService().requestGalleryAccess();
      final pngBytes = await ExportService().captureWidget(_exportKey);
      if (pngBytes == null) throw Exception('Gagal capture gambar');
      final result = await ExportService().saveToGallery(
        pngBytes: pngBytes, format: _format, quality: _quality,
      );
      if (mounted && Navigator.canPop(context)) Navigator.pop(context);
      if (result.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Tersimpan: ${result.path}')),
                ],
              ),
              backgroundColor: Colors.green.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(12),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        throw Exception(result.error ?? 'Gagal export');
      }
    } catch (e) {
      if (mounted && Navigator.canPop(context)) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export gagal: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  // ============= BUILD =============
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_project.template.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_photo_alternate),
            tooltip: 'Isi Otomatis',
            onPressed: _pickMultipleImages,
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Bagikan',
            onPressed: _exporting ? null : _shareResult,
          ),
          IconButton(
            icon: _exporting
                ? const SizedBox(width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.save_alt),
            tooltip: 'Export',
            onPressed: _exporting ? null : _showExportDialog,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final canvasHeight = constraints.maxHeight * 0.55;
          final bottomHeight = constraints.maxHeight - canvasHeight;

          return Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              // ===== LAYER 1: CANVAS (fixed height, DIAM) =====
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: canvasHeight,
                child: Container(
                  color: scheme.surfaceContainerHighest,
                  padding: const EdgeInsets.all(16),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: RepaintBoundary(
                      key: _exportKey,
                      child: GridPreview(
                        template: _project.template,
                        imagePaths: _project.imagePaths,
                        borderWidth: _project.borderWidth,
                        borderColor: _project.borderColor,
                        backgroundColor: _project.backgroundColor,
                        gradientEndColor: _project.gradientEndColor,
                        backgroundType: _project.backgroundType,
                        cellColor: scheme.surfaceContainerHigh,
                        ratio: _project.ratio,
                        cornerRadius: _project.cornerRadius,
                        transforms: _project.transforms,
                        overlays: [
                          ..._project.overlays,
                          if (_panel == BottomPanel.text && _newTextCtrl.text.trim().isNotEmpty)
                            OverlayItem(
                              id: '_preview_',
                              type: OverlayType.text,
                              content: _newTextCtrl.text.trim(),
                              color: _newTextColor,
                              fontSize: _newTextSize,
                              position: const Offset(0.5, 0.9),
                            ),
                        ],
                        onOverlayMove: (idx, pos) {
                          setState(() {
                            _project.overlays[idx] =
                                _project.overlays[idx].copyWith(position: pos);
                          });
                        },
                        onOverlayTap: _editOverlay,
                        onCellTap: (i) {
                          setState(() => _activeCellIndex = i);
                        },
                        onCellPan: (i, delta) {
                          setState(() {
                            final t = _project.transforms[i];
                            t.offset = Offset(
                              (t.offset.dx + delta.dx).clamp(-0.5, 0.5),
                              (t.offset.dy + delta.dy).clamp(-0.5, 0.5),
                            );
                          });
                        },
                        onCellPanEnd: (i) {
                          // optional: save state / trigger re-render
                        },
                      ),
                    ),
                  ),
                ),
              ),

              // ===== LAYER 2: BOTTOM (info + cell picker + toolbar) =====
              Positioned(
                top: canvasHeight,
                left: 0,
                right: 0,
                height: bottomHeight,
                child: Container(
                  color: scheme.surface,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            Text('${_project.filledCount}/${_project.template.cellCount} foto',
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            const Spacer(),
                            if (_project.filledCount > 0)
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    for (int i = 0; i < _project.imagePaths.length; i++) {
                                      _project.setImage(i, null);
                                    }
                                  });
                                },
                                icon: const Icon(Icons.clear_all, size: 16),
                                label: const Text('Kosongkan'),
                              ),
                          ],
                        ),
                      ),
                      Expanded(child: _buildCellPicker()),
                      _buildToolbar(),
                    ],
                  ),
                ),
              ),

              // ===== LAYER 3: PANEL OVERLAY =====
              if (_panel != BottomPanel.none)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 68,
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      border: Border(
                        top: BorderSide(color: scheme.outlineVariant, width: 1),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: _buildPanelContent(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPanelContent() {
    final scheme = Theme.of(context).colorScheme;

    switch (_panel) {
      case BottomPanel.none:
        return const SizedBox.shrink();

      case BottomPanel.border:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(children: [
                const Icon(Icons.line_weight, size: 18),
                const SizedBox(width: 8),
                const Text('Tebal Border',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                Text('${_project.borderWidth.toStringAsFixed(1)}px',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ]),
              Slider(
                value: _project.borderWidth, min: 0, max: 20, divisions: 40,
                label: '${_project.borderWidth.toStringAsFixed(1)}px',
                onChanged: (v) {
                  setState(() => _project.borderWidth = v);
                  EditorSettingsService().saveBorderWidth(v);
                },
              ),
            ],
          ),
        );

      case BottomPanel.corner:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(children: [
                const Icon(Icons.rounded_corner, size: 18),
                const SizedBox(width: 8),
                const Text('Sudut Melengkung',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                Text('${_project.cornerRadius.round()}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ]),
              Slider(
                value: _project.cornerRadius, min: 0, max: 30, divisions: 30,
                onChanged: (v) {
                  setState(() => _project.cornerRadius = v);
                  EditorSettingsService().saveCornerRadius(v);
                },
              ),
            ],
          ),
        );

      case BottomPanel.background:
        return SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(spacing: 8, children: BackgroundType.values.map((t) =>
                ChoiceChip(
                  label: Text(t.label),
                  selected: _project.backgroundType == t,
                  onSelected: (_) {
                    setState(() => _project.backgroundType = t);
                    EditorSettingsService().saveBgType(BackgroundType.values.indexOf(t));
                  },
                )).toList(),
              ),
              const SizedBox(height: 12),
              if (_project.backgroundType == BackgroundType.solid)
                _colorSwatches(
                  _project.backgroundColor,
                  (c) {
                    setState(() => _project.backgroundColor = c);
                    EditorSettingsService().saveBgColor(c);
                  },
                ),
              if (_project.backgroundType == BackgroundType.gradient) ...[
                const Text('Warna Awal', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                _colorSwatches(
                  _project.backgroundColor,
                  (c) => setState(() => _project.backgroundColor = c),
                ),
                const SizedBox(height: 8),
                const Text('Warna Akhir', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                _colorSwatches(
                  _project.gradientEndColor ?? _project.backgroundColor,
                  (c) => setState(() => _project.gradientEndColor = c),
                ),
              ],
              if (_project.backgroundType == BackgroundType.blurredImage)
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('Blur otomatis dari foto pertama',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                ),
            ],
          ),
        );

      case BottomPanel.text:
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _newTextCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Tulis teks...',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6, runSpacing: 6,
                children: [
                  Colors.white, Colors.black, Colors.red, Colors.yellow,
                  Colors.green, Colors.blue, Colors.purple, Colors.orange,
                ].map((c) => GestureDetector(
                  onTap: () => setState(() => _newTextColor = c),
                  child: Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      color: c, shape: BoxShape.circle,
                      border: Border.all(
                        color: _newTextColor == c ? Colors.blue : Colors.grey,
                        width: _newTextColor == c ? 3 : 1,
                      ),
                    ),
                  ),
                )).toList(),
              ),
              Row(
                children: [
                  const Text('Size', style: TextStyle(fontSize: 12)),
                  Expanded(
                    child: Slider(
                      value: _newTextSize, min: 12, max: 72, divisions: 30,
                      label: '${_newTextSize.round()}',
                      onChanged: (v) => setState(() => _newTextSize = v),
                    ),
                  ),
                  Text('${_newTextSize.round()}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _commitText,
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Tambah'),
                  ),
                ],
              ),
            ],
          ),
        );

      case BottomPanel.emoji:
        // Emoji grid langsung di panel
        final emojis = [
          '😀','😂','😍','🥰','😎','🤔','😴','😭','😡','🤯',
          '❤️','💕','💖','✨','⭐','🌟','🔥','💯','🎉','🎊',
          '🌈','☀️','🌙','⚡','🌸','🌺','🍕','🍔','☕','🍰',
          '🐱','🐶','🦄','🐼','🦋','🌻','🎈','🎁','👍','👏',
        ];
        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 8,
            mainAxisSpacing: 2,
            crossAxisSpacing: 2,
          ),
          itemCount: emojis.length,
          itemBuilder: (_, i) => GestureDetector(
            onTap: () {
              setState(() {
                _project.overlays.add(OverlayItem(
                  id: const Uuid().v4(),
                  type: OverlayType.emoji,
                  content: emojis[i],
                  fontSize: 36,
                ));
              });
            },
            child: Center(
              child: Text(emojis[i], style: const TextStyle(fontSize: 22)),
            ),
          ),
        );

      case BottomPanel.filter:
        // Auto-pilih cell pertama kalau belum ada
        if (_activeCellIndex == null) {
          final firstFilled = _project.imagePaths.indexWhere((p) => p != null);
          if (firstFilled == -1) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('Belum ada foto. Isi foto dulu.',
                    style: TextStyle(color: Colors.grey)),
              ),
            );
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _activeCellIndex = firstFilled);
          });
          return const Center(child: CircularProgressIndicator());
        }
        final t = _project.transforms[_activeCellIndex!];
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Icon(Icons.tune, size: 18),
                const SizedBox(width: 8),
                Text('Filter Cell ${_activeCellIndex! + 1}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                TextButton(
                  onPressed: () => setState(() => t.resetFilter()),
                  child: const Text('Reset'),
                ),
              ]),
              _filterRow('Brightness', t.brightness, -1.0, 1.0, (v) {
                setState(() => t.brightness = v);
              }),
              _filterRow('Contrast', t.contrast, 0.5, 2.0, (v) {
                setState(() => t.contrast = v);
              }),
              _filterRow('Saturation', t.saturation, 0.0, 2.0, (v) {
                setState(() => t.saturation = v);
              }),
              _filterRow('Warmth', t.warmth, -1.0, 1.0, (v) {
                setState(() => t.warmth = v);
              }),
            ],
          ),
        );

      case BottomPanel.transform:
        if (_activeCellIndex == null) return const SizedBox.shrink();
        final t = _project.transforms[_activeCellIndex!];
        return SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, size: 20),
                  tooltip: 'Kembali',
                  onPressed: () => setState(() {
                    _panel = BottomPanel.none;
                    _activeCellIndex = null;
                  }),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                Icon(Icons.edit, size: 18, color: scheme.primary),
                const SizedBox(width: 6),
                Text('Cell ${_activeCellIndex! + 1}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                TextButton(
                  onPressed: () => setState(() => t.reset()),
                  child: const Text('Reset'),
                ),
              ]),
              Row(children: [
                const Text('Zoom'),
                const Spacer(),
                Text('${t.zoom.toStringAsFixed(1)}x',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ]),
              Slider(
                value: t.zoom, min: 1.0, max: 3.0, divisions: 20,
                onChanged: (v) => setState(() => t.zoom = v),
              ),
              Row(children: [
                const Text('Rotasi'),
                const Spacer(),
                Text('${(t.rotation * 180 / 3.14159).round()}°',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ]),
              Slider(
                value: t.rotation, min: -3.14159, max: 3.14159, divisions: 12,
                onChanged: (v) => setState(() => t.rotation = v),
              ),
              const SizedBox(height: 8),
              Row(children: [
                FilterChip(
                  label: const Text('Flip H'),
                  selected: t.flipH,
                  onSelected: (v) => setState(() => t.flipH = v),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Flip V'),
                  selected: t.flipV,
                  onSelected: (v) => setState(() => t.flipV = v),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: () => setState(() {
                    _panel = BottomPanel.none;
                    _activeCellIndex = null;
                  }),
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('Selesai'),
                ),
              ]),
            ],
          ),
        );
    }
  }

  Widget _colorSwatches(Color selected, ValueChanged<Color> onPick) {
    final colors = <Color>[
      Colors.white, Colors.black, const Color(0xFFF5F5F5),
      const Color(0xFF212121), const Color(0xFF6750A4),
      const Color(0xFFE57373), const Color(0xFFFFB74D),
      const Color(0xFF64B5F6), const Color(0xFF81C784),
      const Color(0xFFBA68C8),
    ];
    return Wrap(
      spacing: 6, runSpacing: 6,
      children: colors.map((c) {
        final sel = c.value == selected.value;
        return GestureDetector(
          onTap: () => onPick(c),
          child: Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: c, shape: BoxShape.circle,
              border: Border.all(
                color: sel ? Colors.blue : Colors.grey.shade400,
                width: sel ? 3 : 1,
              ),
            ),
            child: sel ? Icon(Icons.check, size: 16,
                color: c.computeLuminance() > 0.5 ? Colors.black : Colors.white) : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCellPicker() {
    final scheme = Theme.of(context).colorScheme;
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: _project.template.cellCount,
      itemBuilder: (_, i) {
        final path = _project.imagePaths[i];
        return GestureDetector(
          onTap: () => _pickImageForCell(i),
          onLongPress: path != null ? () => _showCellMenu(i) : null,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: path != null ? scheme.primary : scheme.outlineVariant,
                width: path != null ? 2 : 1,
              ),
              color: scheme.surfaceContainerLow,
            ),
            clipBehavior: Clip.antiAlias,
            child: path != null
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(
                        File(path),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.broken_image),
                      ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(2),
                          child: Text(
                            '${i + 1}',
                            style: const TextStyle(
                                fontSize: 10, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined,
                            color: scheme.primary),
                        const SizedBox(height: 4),
                        Text(
                          '${i + 1}',
                          style: TextStyle(
                              fontSize: 10, color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }

  Future<void> _showTemplatePicker() async {
    final variants = SmartGridService.variantsFor(_project.imagePaths.length);
    final picked = await showModalBottomSheet<GridTemplate>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Pilih Template',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: variants.length,
                itemBuilder: (c, i) {
                  final tpl = variants[i];
                  final isSelected = tpl.id == _project.template.id;
                  final scheme = Theme.of(context).colorScheme;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx, tpl),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: scheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected ? scheme.primary : scheme.outlineVariant,
                                width: isSelected ? 2.5 : 1,
                              ),
                            ),
                            padding: const EdgeInsets.all(4),
                            child: CustomPaint(
                              painter: _MiniGridPainter(template: tpl),
                            ),
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            width: 76,
                            child: Text(
                              tpl.name,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? scheme.primary : scheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );

    if (picked == null) return;
    if (picked.id == _project.template.id) return;

    setState(() {
      // Simpan settings lama
      final oldImages = List<String?>.from(_project.imagePaths);
      final oldBorder = _project.borderWidth;
      final oldBorderColor = _project.borderColor;
      final oldBg = _project.backgroundColor;
      final oldGrad = _project.gradientEndColor;
      final oldBgType = _project.backgroundType;
      final oldRatio = _project.ratio;
      final oldCorner = _project.cornerRadius;
      final oldOverlays = List<OverlayItem>.from(_project.overlays);

      // Buat project baru dengan template baru
      final newProject = GridProject(template: picked);
      newProject.borderWidth = oldBorder;
      newProject.borderColor = oldBorderColor;
      newProject.backgroundColor = oldBg;
      newProject.gradientEndColor = oldGrad;
      newProject.backgroundType = oldBgType;
      newProject.ratio = oldRatio;
      newProject.cornerRadius = oldCorner;
      newProject.overlays = oldOverlays;

      // Copy foto yang muat
      for (int i = 0; i < newProject.imagePaths.length; i++) {
        if (i < oldImages.length) {
          newProject.imagePaths[i] = oldImages[i];
        }
      }

      _project = newProject;
    });
  }

  void _showTransformPanel() {
    // Kalau belum ada foto aktif, auto-pilih cell pertama yang ada foto
    if (_activeCellIndex == null) {
      final firstFilled = _project.imagePaths.indexWhere((p) => p != null);
      if (firstFilled == -1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Isi foto dulu di salah satu cell.')),
        );
        return;
      }
      setState(() {
        _activeCellIndex = firstFilled;
        _panel = BottomPanel.transform;
      });
    } else {
      setState(() {
        if (_panel == BottomPanel.transform) {
          _panel = BottomPanel.none;
        } else {
          _panel = BottomPanel.transform;
        }
      });
    }
  }

  Widget _buildToolbar() {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: Container(
        height: 68,
        color: scheme.surfaceContainerLow,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            children: [
              _toolBtn(Icons.grid_view, 'Template', BottomPanel.none, scheme, onTapOverride: _showTemplatePicker, forceActive: false),
              _toolBtn(Icons.rotate_right, 'Rotasi', BottomPanel.none, scheme, onTapOverride: _showTransformPanel, forceActive: _panel == BottomPanel.transform),
              _toolBtn(Icons.line_weight, 'Border', BottomPanel.border, scheme),
              _toolBtn(Icons.rounded_corner, 'Sudut', BottomPanel.corner, scheme),
              _toolBtn(Icons.palette_outlined, 'Warna', BottomPanel.background, scheme),
              _toolBtn(Icons.tune, 'Filter', BottomPanel.filter, scheme),
              _toolBtn(Icons.text_fields, 'Teks', BottomPanel.text, scheme),
              _toolBtn(Icons.emoji_emotions_outlined, 'Emoji', BottomPanel.emoji, scheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterRow(String label, double value, double min, double max,
      ValueChanged<double> onChange) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: const TextStyle(fontSize: 12)),
          ),
          Expanded(
            child: Slider(
              value: value, min: min, max: max,
              onChanged: onChange,
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(value.toStringAsFixed(2),
                style: const TextStyle(fontSize: 11),
                textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }

  Widget _toolBtn(IconData icon, String label, BottomPanel panel, ColorScheme scheme, {VoidCallback? onTapOverride, bool? forceActive}) {
    final active = forceActive ?? (_panel == panel && panel != BottomPanel.none);
    return InkWell(
      onTap: () {
        if (onTapOverride != null) {
          onTapOverride();
          return;
        }
        setState(() {
          if (_panel == panel) {
            _panel = BottomPanel.none;
          } else {
            _panel = panel;
            if (panel == BottomPanel.text) {
              _newTextCtrl.clear();
            }
          }
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? scheme.primaryContainer : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22,
                color: active ? scheme.primary : scheme.onSurface),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(fontSize: 11,
                    color: active ? scheme.primary : scheme.onSurface,
                    fontWeight: active ? FontWeight.bold : null)),
          ],
        ),
      ),
    );
  }
}

/// Mini grid painter untuk preview layout template.
class _MiniGridPainter extends CustomPainter {
  final GridTemplate template;
  _MiniGridPainter({required this.template});

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()
      ..color = const Color(0xFFBDBDBD)
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = const Color(0xFF757575)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (final cell in template.cells) {
      final rect = Rect.fromLTWH(
        cell.x * size.width,
        cell.y * size.height,
        cell.w * size.width,
        cell.h * size.height,
      );
      final r = rect.deflate(1);
      canvas.drawRect(r, fill);
      canvas.drawRect(r, stroke);
    }
  }

  @override
  bool shouldRepaint(covariant _MiniGridPainter old) =>
      old.template.id != template.id;
}
