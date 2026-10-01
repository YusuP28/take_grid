import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../../models/grid_project.dart';
import '../../models/grid_template.dart';
import '../../widgets/grid_preview.dart';

class EditorScreen extends StatefulWidget {
  final GridTemplate template;
  const EditorScreen({super.key, required this.template});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late GridProject _project;
  final _picker = ImagePicker();
  int? _activeCell; // cell yang sedang dipilih untuk diisi

  @override
  void initState() {
    super.initState();
    _project = GridProject(template: widget.template);
  }

  Future<void> _pickImageForCell(int index) async {
    try {
      final f = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
        maxWidth: 2048,
      );
      if (f == null) return;
      setState(() {
        _project.setImage(index, f.path);
        _activeCell = null;
      });
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
        imageQuality: 90,
        maxWidth: 2048,
      );
      if (files.isEmpty) return;

      setState(() {
        // Isi cell kosong dulu, lalu overwrite dari awal
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

  void _showBorderSlider() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tebal Border',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.line_weight, size: 18),
                  Expanded(
                    child: Slider(
                      value: _project.borderWidth,
                      min: 0,
                      max: 20,
                      divisions: 20,
                      label: '${_project.borderWidth.round()}px',
                      onChanged: (v) {
                        setLocal(() {});
                        setState(() => _project.borderWidth = v);
                      },
                    ),
                  ),
                  Text('${_project.borderWidth.round()}px',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showColorPicker({required bool forBorder}) {
    Color current = forBorder ? _project.borderColor : _project.backgroundColor;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(forBorder ? 'Warna Border' : 'Warna Background'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: current,
            onColorChanged: (c) {
              setState(() {
                if (forBorder) {
                  _project.borderColor = c;
                } else {
                  _project.backgroundColor = c;
                }
              });
            },
            enableAlpha: false,
            labelTypes: const [],
            pickerAreaHeightPercent: 0.7,
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

  void _showRatioPicker() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Rasio',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const Divider(height: 1),
            ...GridRatio.values.map((r) => ListTile(
                  leading: Icon(_project.ratio == r
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked),
                  title: Text(r.label),
                  onTap: () {
                    setState(() => _project.ratio = r);
                    Navigator.pop(ctx);
                  },
                )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final filled = _project.filledCount;
    final total = _project.template.cellCount;

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
            icon: const Icon(Icons.check),
            tooltip: 'Selesai',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export — Fase 8')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Preview area
          Expanded(
            flex: 5,
            child: Container(
              color: scheme.surfaceContainerHighest,
              padding: const EdgeInsets.all(16),
              child: Center(
                child: GridPreview(
                  template: _project.template,
                  imagePaths: _project.imagePaths,
                  borderWidth: _project.borderWidth,
                  borderColor: _project.borderColor,
                  backgroundColor: _project.backgroundColor,
                  cellColor: scheme.surfaceContainerHigh,
                  ratio: _project.ratio,
                ),
              ),
            ),
          ),

          // Cell picker + info
          Expanded(
            flex: 4,
            child: Container(
              color: scheme.surface,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Text('$filled / $total foto',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        const Spacer(),
                        if (filled > 0)
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
                  // Cell grid picker
                  Expanded(
                    child: GridView.builder(
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
                          onLongPress: path != null ? () => _clearCell(i) : null,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: path != null
                                    ? scheme.primary
                                    : scheme.outlineVariant,
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
                                        // ignore: avoid_slow_async_io
                                        File(path),
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => const Icon(
                                            Icons.broken_image),
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
                                          child: Text('${i + 1}',
                                              style: const TextStyle(
                                                  fontSize: 10, color: Colors.white)),
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
                                        Text('${i + 1}',
                                            style: TextStyle(
                                                fontSize: 10,
                                                color: scheme.onSurfaceVariant)),
                                      ],
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
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
              _toolBtn(Icons.line_weight, 'Border', _showBorderSlider),
              _toolBtn(Icons.palette_outlined, 'Warna',
                  () => _showColorPicker(forBorder: false)),
              _toolBtn(Icons.crop, 'Rasio', _showRatioPicker),
              _toolBtn(Icons.border_color, 'Garis',
                  () => _showColorPicker(forBorder: true)),
            ],
          ),
        ),
      ),
    );
  }

