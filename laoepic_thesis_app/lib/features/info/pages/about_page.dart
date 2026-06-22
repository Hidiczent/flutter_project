
import 'package:flutter/material.dart';
import 'package:laoepic_thesis_app/features/info/pages/contact_page.dart';
import 'package:laoepic_thesis_app/i18n/ui_i18n.dart';
import 'package:laoepic_thesis_app/providers/bottom_nav_provider.dart';
import 'package:laoepic_thesis_app/theme/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

/// Static about screen describing Lao Epic's story, pillars, and tourism focus.
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  String _cleanLead(String text) {
    return text.replaceFirst(RegExp(r'^\s*,\s*'), '').trim();
  }

  @override
  Widget build(BuildContext context) {
    final i18n = context.watch<UiI18n>();

    final laoEpicParagraphs = [
      '${i18n.tr('txt.bold_1')} ${_cleanLead(i18n.tr('txt.about_1'))}',
      '${i18n.tr('txt.bold_1')}${_cleanLead(i18n.tr('txt.about_5'))}',
    ];
    final khodThayParagraphs = [
      '${i18n.tr('txt.bold_2')}${_cleanLead(i18n.tr('txt.about_3'))}',
      _cleanLead(i18n.tr('txt.about_4')),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(i18n.tr('about_page.title')),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Text(
            i18n.tr('about_page.title'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            i18n.tr('about_page.subtitle'),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, height: 1.45, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [AppColors.primary, const Color(0xFF063A6D)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  i18n.tr('about_page.mission_title').toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: Colors.orange.shade200,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  i18n.tr('txt.about_epic2'),
                  style: const TextStyle(
                    fontSize: 17,
                    height: 1.5,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _PillarCard(
            icon: Icons.eco_outlined,
            title: i18n.tr('about_page.pillar_sustainability_title'),
            desc: i18n.tr('about_page.pillar_sustainability_desc'),
            iconColor: Colors.green.shade700,
            bg: Colors.green.shade50,
            border: Colors.green.shade100,
          ),
          const SizedBox(height: 10),
          _PillarCard(
            icon: Icons.groups_outlined,
            title: i18n.tr('about_page.pillar_community_title'),
            desc: i18n.tr('about_page.pillar_community_desc'),
            iconColor: AppColors.primary,
            bg: Colors.blue.shade50,
            border: Colors.blue.shade100,
          ),
          const SizedBox(height: 10),
          _PillarCard(
            icon: Icons.explore_outlined,
            title: i18n.tr('about_page.pillar_discover_title'),
            desc: i18n.tr('about_page.pillar_discover_desc'),
            iconColor: AppColors.accent,
            bg: Colors.orange.shade50,
            border: Colors.orange.shade100,
          ),
          const SizedBox(height: 20),
          _StoryCard(
            badge: i18n.tr('about_page.laoe_badge'),
            brand: i18n.tr('txt.bold_1'),
            logoAsset: 'assets/Logo/LaoEpic Logo 2.svg',
            paragraphs: laoEpicParagraphs,
          ),
          const SizedBox(height: 16),
          _StoryCard(
            badge: i18n.tr('about_page.kt_badge'),
            brand: i18n.tr('txt.bold_2'),
            logoAsset: 'assets/Logo/KT2.svg',
            logoHeight: 100,
            paragraphs: khodThayParagraphs,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    context.read<BottomNavProvider>().changeIndex(1);
                    Navigator.popUntil(context, (r) => r.isFirst);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(i18n.tr('about_page.cta_packages')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ContactPage()),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(i18n.tr('about_page.cta_contact')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PillarCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  final Color iconColor;
  final Color bg;
  final Color border;

  const _PillarCard({
    required this.icon,
    required this.title,
    required this.desc,
    required this.iconColor,
    required this.bg,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(desc, style: TextStyle(fontSize: 13, height: 1.4, color: Colors.grey.shade700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryCard extends StatelessWidget {
  final String badge;
  final String brand;
  final String logoAsset;
  final double logoHeight;
  final List<String> paragraphs;

  const _StoryCard({
    required this.badge,
    required this.brand,
    required this.logoAsset,
    required this.paragraphs,
    this.logoHeight = 72,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFE9EEF2).withValues(alpha: 0.8),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Text(
              badge.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                SvgPicture.asset(logoAsset, height: logoHeight),
                const SizedBox(height: 12),
                Text(
                  brand,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                for (final p in paragraphs)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      p,
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 14, height: 1.55, color: Colors.grey.shade700),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
