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

enum BottomPanel { none, border, corner, background, text, emoji }

class EditorScreen extends StatefulWidget {
  final GridTemplate template;
  final List<String>? initialImages;
  const EditorScreen({super.key, required this.template, this.initialImages});

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

  @override
  void initState() {
    super.initState();
    _project = GridProject(template: widget.template);
    if (widget.initialImages != null) {
      for (int i = 0; i < widget.initialImages!.length; i++) {
        if (i >= _project.imagePaths.length) break;
        _project.setImage(i, widget.initialImages![i]);
      }
    }
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
              onTap: () { Navigator.pop(ctx); _showTransformDialog(index); },
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

  void _showTransformDialog(int index) {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) {
          final t = _project.transforms[index];
          return AlertDialog(
            title: Text('Transform Cell ${index + 1}'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Text('Zoom', style: TextStyle(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Text('${t.zoom.toStringAsFixed(1)}x'),
                  ]),
                  Slider(
                    value: t.zoom, min: 1.0, max: 3.0, divisions: 20,
                    onChanged: (v) {
                      setLocal(() {});
                      setState(() => _project.transforms[index].zoom = v);
                    },
                  ),
                  Row(children: [
                    const Text('Rotasi', style: TextStyle(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Text('${(t.rotation * 180 / 3.14159).round()}°'),
                  ]),
                  Slider(
                    value: t.rotation, min: -3.14159, max: 3.14159, divisions: 12,
                    onChanged: (v) {
                      setLocal(() {});
                      setState(() => _project.transforms[index].rotation = v);
                    },
                  ),
                  const SizedBox(height: 8),
                  const Text('Flip', style: TextStyle(fontWeight: FontWeight.bold)),
                  Row(children: [
                    FilterChip(
                      label: const Text('Horizontal'),
                      selected: t.flipH,
                      onSelected: (v) {
                        setLocal(() {});
                        setState(() => _project.transforms[index].flipH = v);
                      },
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Vertikal'),
                      selected: t.flipV,
                      onSelected: (v) {
                        setLocal(() {});
                        setState(() => _project.transforms[index].flipV = v);
                      },
                    ),
                  ]),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() => _project.transforms[index].reset());
                  Navigator.pop(ctx);
                },
                child: const Text('Reset'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              ),
            ],
          );
        },
      ),
    );
  }

  // ============= OVERLAY =============
  void _addText() {
    final ctrl = TextEditingController();
    Color color = Colors.white;
    double size = 24;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text('Tambah Teks'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: ctrl, autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Tulis teks...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Warna', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  children: [Colors.white, Colors.black, Colors.red,
                    Colors.yellow, Colors.green, Colors.blue,
                    Colors.purple, Colors.orange,
                  ].map((c) => GestureDetector(
                    onTap: () => setLocal(() => color = c),
                    child: Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: c, shape: BoxShape.circle,
                        border: Border.all(
                          color: color == c ? Colors.blue : Colors.grey,
                          width: color == c ? 3 : 1,
                        ),
                      ),
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 12),
                const Text('Ukuran', style: TextStyle(fontWeight: FontWeight.bold)),
                Slider(
                  value: size, min: 12, max: 72, divisions: 30,
                  label: '${size.round()}',
                  onChanged: (v) => setLocal(() => size = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            FilledButton(
              onPressed: () {
                if (ctrl.text.trim().isEmpty) return;
                setState(() {
                  _project.overlays.add(OverlayItem(
                    id: const Uuid().v4(),
                    type: OverlayType.text,
                    content: ctrl.text.trim(),
                    color: color,
                    fontSize: size,
                  ));
                });
                Navigator.pop(ctx);
                setState(() => _panel = BottomPanel.none);
              },
              child: const Text('Tambah'),
            ),
          ],
        ),
      ),
    );
  }

  void _addEmoji() {
    final emojis = [
      '😀','😂','😍','🥰','😎','🤔','😴','😭','😡','🤯',
      '❤️','💕','💖','✨','⭐','🌟','🔥','💯','🎉','🎊',
      '🌈','☀️','🌙','⚡','🌸','🌺','🍕','🍔','☕','🍰',
      '🐱','🐶','🦄','🐼','🦋','🌻','🎈','🎁','👍','👏',
    ];
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Pilih Emoji',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const Divider(height: 1),
            Flexible(
              child: GridView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8, mainAxisSpacing: 8, crossAxisSpacing: 8,
                ),
                itemCount: emojis.length,
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () {
                    setState(() {
                      _project.overlays.add(OverlayItem(
                        id: const Uuid().v4(),
                        type: OverlayType.emoji,
                        content: emojis[i], fontSize: 36,
                      ));
                    });
                    Navigator.pop(ctx);
                    setState(() => _panel = BottomPanel.none);
                  },
                  child: Center(
                    child: Text(emojis[i], style: const TextStyle(fontSize: 28)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
            SnackBar(content: Text('Tersimpan: ${result.path}')),
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
        title: Text(widget.template.name),
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
      body: Column(
        children: [
          // Preview area (canvas)
          Expanded(
            flex: 5,
            child: Container(
              color: scheme.surfaceContainerHighest,
              padding: const EdgeInsets.all(16),
              child: Center(
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
                    overlays: _project.overlays,
                    onOverlayMove: (idx, pos) {
                      setState(() {
                        _project.overlays[idx] =
                            _project.overlays[idx].copyWith(position: pos);
                      });
                    },
                    onOverlayTap: _editOverlay,
                  ),
                ),
              ),
            ),
          ),

          // Bottom panel area (expandable)
          Expanded(
            flex: 4,
            child: Container(
              color: scheme.surface,
              child: Column(
                children: [
                  // Info + clear
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

                  // Panel content (berubah sesuai tab)
                  Expanded(child: _buildPanelContent()),

                  // Cell picker (kalau panel none)
                  if (_panel == BottomPanel.none) _buildCellPicker(),

                  // Tab bar (toolbar)
                  _buildToolbar(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============= PANEL CONTENT =============
  Widget _buildPanelContent() {
    final scheme = Theme.of(context).colorScheme;

    switch (_panel) {
      case BottomPanel.none:
        return const SizedBox.shrink();

      case BottomPanel.border:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
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
                onChanged: (v) => setState(() => _project.borderWidth = v),
              ),
            ],
          ),
        );

      case BottomPanel.corner:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
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
                onChanged: (v) => setState(() => _project.cornerRadius = v),
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
                  onSelected: (_) => setState(() => _project.backgroundType = t),
                )).toList(),
              ),
              const SizedBox(height: 12),
              if (_project.backgroundType == BackgroundType.solid)
                _colorSwatches(
                  _project.backgroundColor,
                  (c) => setState(() => _project.backgroundColor = c),
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
      case BottomPanel.emoji:
        return Center(
          child: TextButton.icon(
            onPressed: _panel == BottomPanel.text ? _addText : _addEmoji,
            icon: const Icon(Icons.add),
            label: Text(_panel == BottomPanel.text ? 'Tambah Teks' : 'Pilih Emoji'),
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
    return Expanded(
      child: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4, mainAxisSpacing: 8, crossAxisSpacing: 8,
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
                  ? Stack(fit: StackFit.expand, children: [
                      Image.file(File(path), fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image)),
                      Positioned(top: 2, right: 2, child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.black54, shape: BoxShape.circle),
                        padding: const EdgeInsets.all(2),
                        child: Text('${i + 1}',
                            style: const TextStyle(fontSize: 10, color: Colors.white)),
                      )),
                    ])
                  : Center(child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined, color: scheme.primary),
                        const SizedBox(height: 4),
                        Text('${i + 1}',
                            style: TextStyle(fontSize: 10, color: scheme.onSurfaceVariant)),
                      ],
                    )),
            ),
          );
        },
      ),
    );
  }

  Widget _buildToolbar() {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Container(
        color: scheme.surfaceContainerLow,
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _toolBtn(Icons.line_weight, 'Border', BottomPanel.border, scheme),
            _toolBtn(Icons.rounded_corner, 'Sudut', BottomPanel.corner, scheme),
            _toolBtn(Icons.palette_outlined, 'Warna', BottomPanel.background, scheme),
            _toolBtn(Icons.text_fields, 'Teks', BottomPanel.text, scheme),
            _toolBtn(Icons.emoji_emotions_outlined, 'Emoji', BottomPanel.emoji, scheme),
          ],
        ),
      ),
    );
  }

  Widget _toolBtn(IconData icon, String label, BottomPanel panel, ColorScheme scheme) {
    final active = _panel == panel;
    return InkWell(
      onTap: () {
        setState(() {
          if (_panel == panel) {
            _panel = BottomPanel.none;
          } else {
            _panel = panel;
            if (panel == BottomPanel.text) {
              WidgetsBinding.instance.addPostFrameCallback((_) => _addText());
            }
            if (panel == BottomPanel.emoji) {
              WidgetsBinding.instance.addPostFrameCallback((_) => _addEmoji());
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
