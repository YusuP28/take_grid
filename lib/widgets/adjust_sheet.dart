import 'package:flutter/material.dart';

/// Bottom sheet wrapper yang jadi 50% transparan saat slider digerakkan
class AdjustSheet extends StatefulWidget {
  final String title;
  final Widget Function(BuildContext, VoidCallback onSliding, VoidCallback onSlidingEnd) builder;

  const AdjustSheet({
    super.key,
    required this.title,
    required this.builder,
  });

  @override
  State<AdjustSheet> createState() => _AdjustSheetState();
}

class _AdjustSheetState extends State<AdjustSheet> {
  bool _sliding = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: _sliding ? 0.5 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(widget.title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            widget.builder(
              context,
              () { if (mounted) setState(() => _sliding = true); },
              () { if (mounted) setState(() => _sliding = false); },
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper: panggil untuk show adjust sheet
Future<void> showAdjustSheet({
  required BuildContext context,
  required String title,
  required Widget Function(BuildContext, VoidCallback, VoidCallback) builder,
}) async {
  await showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => AdjustSheet(title: title, builder: builder),
  );
}
