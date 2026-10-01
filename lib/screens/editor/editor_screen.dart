import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../../models/grid_project.dart';
import '../../models/grid_template.dart';
import '../../widgets/grid_preview.dart';
import '../../services/export_service.dart';
import 'dart:ui' as ui;

class EditorScreen extends StatefulWidget {
  final GridTemplate template;
  const EditorScreen({super.key, required this.template});

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
        imageQuality: 90,
        maxWidth: 2048,
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

  void _clearAll() {
    setState(() {
      for (int i = 0; i < _project.imagePaths.length; i++) {
        _project.setImage(i, null);
      }
    });
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
    if (forBorder) {
      // Langsung color picker border
      Color current = _project.borderColor;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Warna Border'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: current,
              onColorChanged: (c) {
                setState(() => _project.borderColor = c);
              },
              enableAlpha: false,
              labelTypes: const [],
              pickerAreaHeightPercent: 0.7,
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
          ],
        ),
      );
    } else {
      // Background dialog: pilih tipe + warna
      _showBackgroundDialog();
    }
  }

  void _showBackgroundDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Background',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: BackgroundType.values.map((t) => ChoiceChip(
                        label: Text(t.label),
                        selected: _project.backgroundType == t,
                        onSelected: (_) {
                          setState(() => _project.backgroundType = t);
                          setLocal(() {});
                        },
                      )).toList(),
                ),
                const SizedBox(height: 16),
                if (_project.backgroundType == BackgroundType.solid) ...[
                  const Text('Warna'),
                  const SizedBox(height: 8),
                  _colorSwatches(
                    selectedColor: _project.backgroundColor,
                    onPick: (c) {
                      setState(() => _project.backgroundColor = c);
                      setLocal(() {});
                    },
                  ),
                ],
                if (_project.backgroundType == BackgroundType.gradient) ...[
                  const Text('Warna Awal'),
                  const SizedBox(height: 8),
                  _colorSwatches(
                    selectedColor: _project.backgroundColor,
                    onPick: (c) {
                      setState(() => _project.backgroundColor = c);
                      setLocal(() {});
                    },
                  ),
                  const SizedBox(height: 12),
                  const Text('Warna Akhir'),
                  const SizedBox(height: 8),
                  _colorSwatches(
                    selectedColor:
                        _project.gradientEndColor ?? _project.backgroundColor,
                    onPick: (c) {
                      setState(() => _project.gradientEndColor = c);
                      setLocal(() {});
                    },
                  ),
                ],
                if (_project.backgroundType == BackgroundType.blurredImage) ...[
                  const Text('Blur akan diambil dari foto pertama',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Selesai'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _colorSwatches({
    required Color selectedColor,
    required ValueChanged<Color> onPick,
  }) {
    final colors = <Color>[
      Colors.white,
      Colors.black,
      const Color(0xFFF5F5F5),
      const Color(0xFF212121),
      const Color(0xFF6750A4),
      const Color(0xFFE57373),
      const Color(0xFFFFB74D),
      const Color(0xFF64B5F6),
      const Color(0xFF81C784),
      const Color(0xFFBA68C8),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: colors.map((c) {
        final sel = c.value == selectedColor.value;
        return GestureDetector(
          onTap: () => onPick(c),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: c,
              shape: BoxShape.circle,
              border: Border.all(
                color: sel ? Colors.blue : Colors.grey.shade400,
                width: sel ? 3 : 1,
              ),
            ),
            child: sel
                ? Icon(Icons.check,
                    size: 18,
                    color: c.computeLuminance() > 0.5
                        ? Colors.black
                        : Colors.white)
                : null,
          ),
        );
      }).toList(),
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

  void _showCornerSlider() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Sudut Melengkung',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.rounded_corner, size: 18),
                  Expanded(
                    child: Slider(
                      value: _project.cornerRadius,
                      min: 0,
                      max: 30,
                      divisions: 30,
                      label: '${_project.cornerRadius.round()}',
                      onChanged: (v) {
                        setLocal(() {});
                        setState(() => _project.cornerRadius = v);
                      },
                    ),
                  ),
                  Text('${_project.cornerRadius.round()}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _shareResult() async {
    try {
      final pngBytes = await ExportService().captureWidget(_exportKey);
      if (pngBytes == null) throw Exception('Gagal capture');

      final file = await ExportService().saveToTempFile(
        pngBytes: pngBytes,
        format: _format,
        quality: _quality,
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
                const Text('Format',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('JPG')),
                        selected: localFormat == ExportFormat.jpg,
                        onSelected: (_) {
                          setLocal(() => localFormat = ExportFormat.jpg);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('PNG')),
                        selected: localFormat == ExportFormat.png,
                        onSelected: (_) {
                          setLocal(() => localFormat = ExportFormat.png);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Kualitas',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...ExportQuality.values.map((q) => RadioListTile<ExportQuality>(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text('${q.label} (${q.px}px)'),
                      value: q,
                      groupValue: localQuality,
                      onChanged: (v) {
                        if (v != null) {
                          setLocal(() => localQuality = v);
                        }
                      },
                    )),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
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
    try {
      // 1. Cek permission
      final has = await ExportService().hasGalleryAccess();
      if (!has) {
        await ExportService().requestGalleryAccess();
      }

      // 2. Capture widget
      final pngBytes = await ExportService().captureWidget(_exportKey);
      if (pngBytes == null) {
        throw Exception('Gagal capture gambar');
      }

      // 3. Save ke galeri
      final result = await ExportService().saveToGallery(
        pngBytes: pngBytes,
        format: _format,
        quality: _quality,
      );

      if (result.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tersimpan: ${result.path}'),
              action: SnackBarAction(
                label: 'OK',
                onPressed: () {},
              ),
            ),
          );
        }
      } else {
        throw Exception(result.error ?? 'Gagal export');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export gagal: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Widget _toolBtn(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 11)),
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
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Bagikan',
            onPressed: _exporting ? null : _shareResult,
          ),
          IconButton(
            icon: _exporting
                ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_alt),
            tooltip: 'Export',
            onPressed: _exporting ? null : _showExportDialog,
          ),
        ],
      ),
      body: Column(
        children: [
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
                  ),
                ),
              ),
            ),
          ),
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
                            onPressed: _clearAll,
                            icon: const Icon(Icons.clear_all, size: 16),
                            label: const Text('Kosongkan'),
                          ),
                      ],
                    ),
                  ),
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
              _toolBtn(Icons.rounded_corner, 'Sudut', _showCornerSlider),
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
}
