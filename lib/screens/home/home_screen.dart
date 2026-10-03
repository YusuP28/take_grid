import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/grid_template.dart';
import '../../models/grid_project.dart';
import '../../services/smart_grid_service.dart';
import '../../widgets/grid_preview.dart';
import '../editor/editor_screen.dart';
import '../layout_picker/layout_picker_screen.dart';
import '../freestyle/freestyle_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // ============ QUICK TEMPLATE PICKER (dari FAB) ============
  Future<void> _showQuickTemplatePicker(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (_, scrollCtrl) => Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Pilih Template',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const Divider(height: 1),
            Expanded(
              child: GridView.builder(
                controller: scrollCtrl,
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.85,
                ),
                itemCount: GridTemplates.all.length,
                itemBuilder: (_, i) {
                  final tpl = GridTemplates.all[i];
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(ctx);
                      _pickRatioThenOpen(context, tpl);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color:
                            Theme.of(context).colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.3),
                        ),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          Expanded(
                            child: GridPreview(
                              template: tpl,
                              borderWidth: 1.0,
                              borderColor:
                                  Theme.of(context).colorScheme.primary,
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                              cellColor: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHigh,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(tpl.name,
                              style: const TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.w600)),
                          Text('${tpl.cellCount} foto',
                              style: const TextStyle(
                                  fontSize: 9, color: Colors.grey)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickRatioThenOpen(
      BuildContext context, GridTemplate tpl) async {
    final ratio = await showModalBottomSheet<GridRatio>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Pilih Rasio',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const Divider(height: 1),
            ...GridRatio.values.map((r) => ListTile(
                  leading: const Icon(Icons.aspect_ratio),
                  title: Text(r.label),
                  onTap: () => Navigator.pop(ctx, r),
                )),
          ],
        ),
      ),
    );
    if (ratio == null) return;
    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditorScreen(template: tpl, initialRatio: ratio),
      ),
    );
  }

  // ============ AUTO GRID ============
  Future<void> _autoGrid(BuildContext context) async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage(
      imageQuality: 90,
      maxWidth: 2048,
      limit: 20,
    );
    if (files.isEmpty) return;

    if (files.length > 20 && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Max 20 foto. Ambil 20 teratas.')),
      );
    }

    final paths = files.take(20).map((f) => f.path).toList();

    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LayoutPickerScreen(imagePaths: paths),
      ),
    );
  }

  // ============ BUILD ============
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Take Grid'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // === Auto Grid ===
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white),
              ),
              title: const Text('Auto Grid',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              subtitle: const Text('Pilih foto → grid otomatis (max 12)'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _autoGrid(context),
            ),
          ),

          // === Free Style Canvas ===
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.dashboard_customize,
                    color: scheme.onPrimaryContainer),
              ),
              title: const Text('Free Style Canvas',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              subtitle: const Text('Susun foto bebas tanpa grid'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FreeStyleScreen()),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showQuickTemplatePicker(context),
        icon: const Icon(Icons.add_photo_alternate),
        label: const Text('Buat Grid'),
      ),
    );
  }
}
