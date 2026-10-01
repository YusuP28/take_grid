import 'package:flutter/material.dart';
import '../../models/grid_template.dart';
import '../../widgets/grid_preview.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Take Grid'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings: coming soon')),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Pilih Template',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: scheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: GridTemplates.all.length,
            itemBuilder: (_, i) {
              final tpl = GridTemplates.all[i];
              return GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Pilih: ${tpl.name} (Fase 4)')),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: scheme.primary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      Expanded(
                        child: GridPreview(
                          template: tpl,
                          borderWidth: 1.0,
                          borderColor: scheme.primary,
                          backgroundColor: scheme.surfaceContainerHighest,
                          cellColor: scheme.surfaceContainerHigh,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        tpl.name,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${tpl.cellCount} foto',
                        style: TextStyle(fontSize: 10, color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Buat Grid — coming soon')),
          );
        },
        icon: const Icon(Icons.add_photo_alternate),
        label: const Text('Buat Grid'),
      ),
    );
  }
}
