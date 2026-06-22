
import 'package:flutter/material.dart';
import 'package:laoepic_thesis_app/i18n/ui_i18n.dart';
import 'package:laoepic_thesis_app/theme/app_colors.dart';
import 'package:provider/provider.dart';

/// Simple scrollable info page (About / Contact / Help) driven by i18n body key.
class InfoTextPage extends StatelessWidget {
  final String titleKey;
  final String bodyKey;

  const InfoTextPage({
    super.key,
    required this.titleKey,
    required this.bodyKey,
  });

  @override
  Widget build(BuildContext context) {
    final i18n = context.watch<UiI18n>();
    final paragraphs = i18n.tr(bodyKey).split('\n\n');
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(i18n.tr(titleKey)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          for (final p in paragraphs)
            if (p.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Text(
                  p.trim(),
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.55,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
