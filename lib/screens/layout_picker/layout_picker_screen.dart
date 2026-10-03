import 'package:flutter/material.dart';

import '../../models/grid_template.dart';
import '../../services/smart_grid_service.dart';
import '../../widgets/grid_preview.dart';
import '../editor/editor_screen.dart';

/// Layar untuk memilih layout/template grid setelah user pilih foto.
/// Menampilkan preview + baris varian template yang cocok dengan jumlah foto.
class LayoutPickerScreen extends StatefulWidget {
  final List<String> imagePaths;

  const LayoutPickerScreen({super.key, required this.imagePaths});

  @override
  State<LayoutPickerScreen> createState() => _LayoutPickerScreenState();
}

class _LayoutPickerScreenState extends State<LayoutPickerScreen> {
  late final List<GridTemplate> _variants;
  late GridTemplate _selected;

  @override
  void initState() {
    super.initState();
    _variants = SmartGridService.variantsFor(widget.imagePaths.length);
    _selected = _variants.first;
  }

  void _onNext() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => EditorScreen(
          template: _selected,
          initialImages: widget.imagePaths,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.imagePaths.length} Foto'),
        actions: [
          TextButton(
            onPressed: _onNext,
            child: const Text('LANJUT'),
          ),
        ],
      ),
      body: Column(
        children: [
          // ===== PREVIEW CANVAS =====
          Expanded(
            flex: 5,
            child: Container(
              color: scheme.surfaceContainerHighest,
              padding: const EdgeInsets.all(16),
              child: Center(
                child: GridPreview(
                  template: _selected,
                  imagePaths: widget.imagePaths,
                  cellColor: scheme.surfaceContainerHigh,
                ),
              ),
            ),
          ),

          // ===== TEMPLATE PICKER (horizontal scroll) =====
          Container(
            height: 120,
            color: scheme.surface,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _variants.length,
              itemBuilder: (ctx, i) {
                final tpl = _variants[i];
                final isSelected = tpl.id == _selected.id;
                return _TemplateTile(
                  template: tpl,
                  isSelected: isSelected,
                  onTap: () => setState(() => _selected = tpl),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Satu tile template di baris picker.
class _TemplateTile extends StatelessWidget {
  final GridTemplate template;
  final bool isSelected;
  final VoidCallback onTap;

  const _TemplateTile({
    required this.template,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: GestureDetector(
        onTap: onTap,
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
                painter: _MiniGridPainter(template: template),
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 76,
              child: Text(
                template.name,
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
  }
}

/// Painter mini preview layout template (kotak-kotak).
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
      // inset kecil biar ada jarak antar cell
      final r = rect.deflate(1);
      canvas.drawRect(r, fill);
      canvas.drawRect(r, stroke);
    }
  }

  @override
  bool shouldRepaint(covariant _MiniGridPainter old) =>
      old.template.id != template.id;
}
