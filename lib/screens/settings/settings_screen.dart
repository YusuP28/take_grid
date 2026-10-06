import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _autoSave = true;
  bool _hdDefault = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _autoSave = p.getBool('auto_save') ?? true;
      _hdDefault = p.getBool('hd_default') ?? true;
    });
  }

  Future<void> _save(String key, bool v) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(key, v);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        children: [
          _section('Umum'),
          SwitchListTile(
            secondary: const Icon(Icons.save_outlined),
            title: const Text('Auto Save ke Galeri'),
            subtitle: const Text('Simpan otomatis setelah export'),
            value: _autoSave,
            onChanged: (v) {
              setState(() => _autoSave = v);
              _save('auto_save', v);
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.high_quality),
            title: const Text('Kualitas HD Default'),
            subtitle: const Text('Export pakai 1080p default'),
            value: _hdDefault,
            onChanged: (v) {
              setState(() => _hdDefault = v);
              _save('hd_default', v);
            },
          ),
          const Divider(),
          _section('Tentang'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Take Grid'),
            subtitle: Text('Versi 1.2.0'),
          ),
          ListTile(
            leading: const Icon(Icons.grid_on),
            title: const Text('Fitur'),
            subtitle: Text(
              '8 template grid + free style canvas\n'
              'Border, warna, rasio, rounded corner\n'
              'Background solid/gradient/blur\n'
              'Crop, zoom, rotate, flip per cell\n'
              'Teks + emoji interaktif\n'
              'Export JPG/PNG 720p-4K',
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '© 2026 Take Grid — Personal project',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
        ),
      );
}
