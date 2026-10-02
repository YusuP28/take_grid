import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../../models/freestyle_item.dart';
import '../../services/export_service.dart';

class FreeStyleScreen extends StatefulWidget {
  const FreeStyleScreen({super.key});

  @override
  State<FreeStyleScreen> createState() => _FreeStyleScreenState();
}

class _FreeStyleScreenState extends State<FreeStyleScreen> {
  final _picker = ImagePicker();
  final _exportKey = GlobalKey();
  final List<FreeStyleItem> _items = [];
  Color _bgColor = Colors.white;
  bool _exporting = false;
  int? _activeIndex;

  Future<void> _addImage() async {
    try {
      final f = await _picker.pickImage(source: ImageSource.gallery);
      if (f == null) return;
      setState(() {
        _items.add(FreeStyleItem(
          id: const Uuid().v4(),
          type: FreeStyleType.image,
          content: f.path,
          position: const Offset(0.5, 0.5),
          scale: 0.4,
        ));
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e')),
        );
      }
    }
  }

  void _addText() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Teks'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Tulis teks...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              if (ctrl.text.trim().isEmpty) return;
              setState(() {
                _items.add(FreeStyleItem(
                  id: const Uuid().v4(),
                  type: FreeStyleType.text,
                  content: ctrl.text.trim(),
                  position: const Offset(0.5, 0.5),
                  scale: 0.5,
                ));
              });
              Navigator.pop(ctx);
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  void _showBackgroundPicker() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Warna Background'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _bgColor,
            onColorChanged: (c) => setState(() => _bgColor = c),
            enableAlpha: false,
            labelTypes: const [],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _export() async {
    setState(() => _exporting = true);
    try {
      final has = await ExportService().hasGalleryAccess();
      if (!has) await ExportService().requestGalleryAccess();

      final bytes = await ExportService().captureWidget(_exportKey);
      if (bytes == null) throw Exception('Capture gagal');

      final r = await ExportService().saveToGallery(
        pngBytes: bytes,
        format: ExportFormat.png,
        quality: ExportQuality.fhd1080,
      );

      if (r.success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tersimpan: ${r.path}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Free Style'),
        actions: [
          IconButton(
            icon: const Icon(Icons.palette),
            tooltip: 'Background',
            onPressed: _showBackgroundPicker,
          ),
          IconButton(
            icon: _exporting
                ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_alt),
            tooltip: 'Export',
            onPressed: _exporting ? null : _export,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Canvas — fixed, tidak bergerak saat control muncul
          Positioned.fill(
            bottom: _activeIndex != null ? 170 : 0,
            child: Container(
              color: scheme.surfaceContainerHighest,
              padding: const EdgeInsets.all(16),
              child: Center(
                child: RepaintBoundary(
                  key: _exportKey,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      color: _bgColor,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final w = constraints.maxWidth;
                          final h = constraints.maxHeight;
                          return Stack(
                            children: _items.asMap().entries.map((entry) {
                              final idx = entry.key;
                              final item = entry.value;
                              final isActive = _activeIndex == idx;
                              return Positioned(
                                left: item.position.dx * w - 60 * item.scale,
                                top: item.position.dy * h - 30 * item.scale,
                                child: GestureDetector(
                                  onTap: () => setState(
                                      () => _activeIndex = isActive ? null : idx),
                                  onPanUpdate: (d) {
                                    setState(() {
                                      item.position = Offset(
                                        (item.position.dx + d.delta.dx / w)
                                            .clamp(0.0, 1.0),
                                        (item.position.dy + d.delta.dy / h)
                                            .clamp(0.0, 1.0),
                                      );
                                    });
                                  },
                                  child: Container(
                                    decoration: isActive
                                        ? BoxDecoration(
                                            border: Border.all(
                                                color: Colors.blue, width: 2),
                                          )
                                        : null,
                                    child: Transform.rotate(
                                      angle: item.rotation,
                                      child: _buildItem(item),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Control bar — overlay di bawah (tidak dorong canvas)
          if (_activeIndex != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                color: scheme.surfaceContainerLow,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Baris 1: Zoom
                    Row(
                      children: [
                        const Icon(Icons.zoom_in, size: 18),
                        Expanded(
                          child: Slider(
                            value: _items[_activeIndex!].scale,
                            min: 0.1,
                            max: 1.5,
                            onChanged: (v) => setState(
                                () => _items[_activeIndex!].scale = v),
                          ),
                        ),
                      ],
                    ),
                    // Baris 2: Rotasi
                    Row(
                      children: [
                        const Icon(Icons.rotate_right, size: 18),
                        Expanded(
                          child: Slider(
                            value: _items[_activeIndex!].rotation,
                            min: -3.14159,
                            max: 3.14159,
                            divisions: 24,
                            onChanged: (v) => setState(
                                () => _items[_activeIndex!].rotation = v),
                          ),
                        ),
                      ],
                    ),
                    // Baris 3: Reset + Hapus
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () => setState(() {
                            _items[_activeIndex!].scale = 0.4;
                            _items[_activeIndex!].rotation = 0;
                          }),
                          icon: const Icon(Icons.restart_alt, size: 18),
                          label: const Text('Reset'),
                        ),
                        TextButton.icon(
                          onPressed: () => setState(() {
                            _items.removeAt(_activeIndex!);
                            _activeIndex = null;
                          }),
                          icon: Icon(Icons.delete,
                              color: scheme.error, size: 18),
                          label: Text('Hapus',
                              style: TextStyle(color: scheme.error)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          color: scheme.surfaceContainerLow,
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _toolBtn(Icons.photo_library, 'Foto', _addImage),
              _toolBtn(Icons.text_fields, 'Teks', _addText),
              _toolBtn(Icons.layers_clear, 'Bersihkan', () {
                setState(() {
                  _items.clear();
                  _activeIndex = null;
                });
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(FreeStyleItem item) {
    switch (item.type) {
      case FreeStyleType.image:
        return SizedBox(
          width: 120 * item.scale,
          height: 120 * item.scale,
          child: Image.file(
            File(item.content),
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
          ),
        );
      case FreeStyleType.text:
        return Text(
          item.content,
          style: TextStyle(
            fontSize: 24 * item.scale,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            shadows: const [
              Shadow(offset: Offset(1, 1), blurRadius: 2, color: Colors.white),
            ],
          ),
        );
      case FreeStyleType.sticker:
        return Text(
          item.content,
          style: TextStyle(fontSize: 36 * item.scale),
        );
    }
  }

  Widget _toolBtn(IconData icon, String label, VoidCallback onTap) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: scheme.onSurface),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(fontSize: 11, color: scheme.onSurface)),
          ],
        ),
      ),
    );
  }
}
