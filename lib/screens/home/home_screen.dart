import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/grid_template.dart';
import '../../models/grid_project.dart';
import '../../services/project_service.dart';
import '../../services/smart_grid_service.dart';
import '../../widgets/grid_preview.dart';
import '../editor/editor_screen.dart';
import '../freestyle/freestyle_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _service = ProjectService();
  List<ProjectMeta> _projects = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final list = await _service.listProjects();
    if (!mounted) return;
    setState(() {
      _projects = list;
      _loading = false;
    });
  }

  // ============ QUICK TEMPLATE PICKER (dari FAB) ============
  Future<void> _showQuickTemplatePicker() async {
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
                      _pickRatioThenOpen(tpl);
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

  Future<void> _pickRatioThenOpen(GridTemplate tpl) async {
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
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditorScreen(template: tpl, initialRatio: ratio),
      ),
    );
    _refresh();
  }

  // ============ AUTO GRID ============
  Future<void> _autoGrid() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage(
      imageQuality: 90,
      maxWidth: 2048,
      limit: 20, // max untuk auto-grid (12 cell terbanyak)
    );
    if (files.isEmpty) return;

    if (files.length > 20 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Max 20 foto. Ambil 20 teratas.')),
      );
    }

    final paths = files.take(20).map((f) => f.path).toList();
    final template = SmartGridService.forPhotoCount(paths.length);

    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditorScreen(
          template: template,
          initialImages: paths,
        ),
      ),
    );
    _refresh();
  }

  // ============ OPEN PROJECT ============
  Future<void> _openProject(ProjectMeta meta) async {
    final template = GridTemplates.byIdOrFirst(meta.templateId);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditorScreen(
          template: template,
          projectId: meta.id,
        ),
      ),
    );
    _refresh();
  }

  Future<void> _confirmDelete(ProjectMeta meta) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Project?'),
        content: Text('"${meta.name}" akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await _service.deleteProject(meta.id);
    if (meta.thumbnailPath != null) {
      final f = File(meta.thumbnailPath!);
      if (f.existsSync()) {
        try {
          f.deleteSync();
        } catch (_) {}
      }
    }
    _refresh();
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
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
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
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                subtitle: const Text('Pilih foto → grid otomatis (max 12)'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _autoGrid,
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
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                subtitle: const Text('Susun foto bebas tanpa grid'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FreeStyleScreen()),
                  );
                  _refresh();
                },
              ),
            ),

            // === Drafts section ===
            if (!_loading && _projects.isNotEmpty) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Text('Drafts',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: scheme.primary)),
                    const SizedBox(width: 8),
                    Text('(${_projects.length})',
                        style: TextStyle(
                            fontSize: 13, color: scheme.onSurfaceVariant)),
                  ],
                ),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.78,
                ),
                itemCount: _projects.length,
                itemBuilder: (_, i) {
                  final meta = _projects[i];
                  return _ProjectCard(
                    meta: meta,
                    onTap: () => _openProject(meta),
                    onDelete: () => _confirmDelete(meta),
                  );
                },
              ),
              const SizedBox(height: 80),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showQuickTemplatePicker,
        icon: const Icon(Icons.add_photo_alternate),
        label: const Text('Buat Grid'),
      ),
    );
  }
}

// ============ PROJECT CARD ============
class _ProjectCard extends StatelessWidget {
  final ProjectMeta meta;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ProjectCard({
    required this.meta,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      onLongPress: onDelete,
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: scheme.outlineVariant.withOpacity(0.5),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _buildThumb(scheme),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meta.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.photo_library_outlined,
                          size: 11, color: scheme.onSurfaceVariant),
                      const SizedBox(width: 3),
                      Text(
                        '${meta.filledCount}/${meta.cellCount}',
                        style: TextStyle(
                            fontSize: 10, color: scheme.onSurfaceVariant),
                      ),
                      const Spacer(),
                      Text(
                        _formatDate(meta.updatedAt),
                        style: TextStyle(
                            fontSize: 10, color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumb(ColorScheme scheme) {
    final path = meta.thumbnailPath;
    if (path != null && File(path).existsSync()) {
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(scheme),
      );
    }
    return _placeholder(scheme);
  }

  Widget _placeholder(ColorScheme scheme) {
    final tpl = GridTemplates.byId(meta.templateId);
    if (tpl != null) {
      return Container(
        color: scheme.surfaceContainerHighest,
        padding: const EdgeInsets.all(12),
        child: GridPreview(
          template: tpl,
          borderWidth: 1.5,
          borderColor: scheme.primary.withOpacity(0.6),
          backgroundColor: scheme.surfaceContainerHighest,
          cellColor: scheme.surfaceContainerHigh,
        ),
      );
    }
    return Container(
      color: scheme.surfaceContainerHighest,
      child: Icon(Icons.image_outlined,
          size: 32, color: scheme.onSurfaceVariant),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'baru';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}j';
    if (diff.inDays < 7) return '${diff.inDays}h';
    return '${dt.day}/${dt.month}';
  }
}
