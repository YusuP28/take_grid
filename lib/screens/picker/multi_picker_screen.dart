import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

/// Custom multi-picker dengan HARD LIMIT.
/// Return: List<File> yang sudah dipilih (max = [maxCount]).
class MultiPickerScreen extends StatefulWidget {
  final int maxCount;
  final String title;

  const MultiPickerScreen({
    super.key,
    required this.maxCount,
    this.title = 'Pilih Foto',
  });

  @override
  State<MultiPickerScreen> createState() => _MultiPickerScreenState();
}

class _MultiPickerScreenState extends State<MultiPickerScreen> {
  List<AssetEntity> _assets = [];
  final Set<String> _selectedIds = {};
  bool _loading = true;
  bool _hasPermission = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final perm = await PhotoManager.requestPermissionExtend();
      if (!mounted) return;
      if (!perm.isAuth && !perm.hasAccess) {
        setState(() {
          _loading = false;
          _hasPermission = false;
          _error = 'Izin galeri ditolak. Buka Settings → Apps → Take Grid → Permissions.';
        });
        return;
      }
      setState(() => _hasPermission = true);

      // Ambil asset terbaru dari semua album
      final albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        onlyAll: true,
      );
      if (albums.isEmpty) {
        setState(() {
          _loading = false;
          _error = 'Galeri kosong';
        });
        return;
      }

      final all = albums.first;
      final assets = await all.getAssetListRange(start: 0, end: 500);

      if (!mounted) return;
      setState(() {
        _assets = assets;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Gagal load: $e';
      });
    }
  }

  void _toggleSelect(AssetEntity asset) {
    final id = asset.id;
    if (_selectedIds.contains(id)) {
      setState(() => _selectedIds.remove(id));
      return;
    }
    if (_selectedIds.length >= widget.maxCount) {
      // Hard-block: kasih feedback
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Max ${widget.maxCount} foto untuk template ini'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _selectedIds.add(id));
  }

  Future<void> _confirm() async {
    if (_selectedIds.isEmpty) return;
    // Urutkan sesuai urutan di grid (bukan urutan tap)
    final ordered = _assets
        .where((a) => _selectedIds.contains(a.id))
        .toList();

    final files = <File>[];
    for (final asset in ordered) {
      final f = await asset.file;
      if (f != null) files.add(f);
    }
    if (!mounted) return;
    Navigator.pop(context, files);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final selected = _selectedIds.length;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.title),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: selected == widget.maxCount
                    ? scheme.primary
                    : scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$selected/${widget.maxCount}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: selected == widget.maxCount
                      ? scheme.onPrimary
                      : scheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _buildBody(scheme),
      bottomNavigationBar: _buildBottomBar(scheme),
    );
  }

  Widget _buildBody(ColorScheme scheme) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!_hasPermission || _error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline, size: 64, color: scheme.error),
              const SizedBox(height: 16),
              Text(
                _error ?? 'Izin ditolak',
                textAlign: TextAlign.center,
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: PhotoManager.openSetting,
                child: const Text('Buka Settings'),
              ),
            ],
          ),
        ),
      );
    }
    if (_assets.isEmpty) {
      return Center(
        child: Text('Tidak ada foto',
            style: TextStyle(color: scheme.onSurfaceVariant)),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemCount: _assets.length,
      itemBuilder: (_, i) => _buildTile(_assets[i], i, scheme),
    );
  }

  Widget _buildTile(AssetEntity asset, int index, ColorScheme scheme) {
    final isSelected = _selectedIds.contains(asset.id);
    // Nomor urut tampil di badge kalau selected
    final orderNum = isSelected
        ? _assets
                .where((a) => _selectedIds.contains(a.id))
                .toList()
                .indexWhere((a) => a.id == asset.id) +
            1
        : 0;

    return GestureDetector(
      onTap: () => _toggleSelect(asset),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: FutureBuilder<File?>(
              future: asset.file,
              builder: (ctx, snap) {
                if (!snap.hasData || snap.data == null) {
                  return Container(color: scheme.surfaceContainerHighest);
                }
                return Image.file(
                  snap.data!,
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                  cacheWidth: 200,
                );
              },
            ),
          ),
          // Overlay selected
          if (isSelected)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: scheme.primary, width: 3),
                color: scheme.primary.withOpacity(0.25),
              ),
            ),
          // Badge nomor urut
          if (isSelected)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$orderNum',
                  style: TextStyle(
                    color: scheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          if (!isSelected)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white70, width: 2),
                  color: Colors.black26,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(ColorScheme scheme) {
    final selected = _selectedIds.length;
    final canConfirm = selected > 0;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                canConfirm
                    ? '$selected foto dipilih'
                    : 'Pilih foto (max ${widget.maxCount})',
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
            ),
            FilledButton.icon(
              onPressed: canConfirm ? _confirm : null,
              icon: const Icon(Icons.check, size: 18),
              label: Text('Selesai${canConfirm ? ' ($selected)' : ''}'),
            ),
          ],
        ),
      ),
    );
  }
}
