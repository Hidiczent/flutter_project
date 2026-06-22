
import 'package:flutter/material.dart';
import 'package:laoepic_thesis_app/features/info/pages/help_center_page.dart';
import 'package:laoepic_thesis_app/i18n/ui_i18n.dart';
import 'package:laoepic_thesis_app/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// Contact screen with support channels, office details, and social links.
class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  Future<void> _open(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final i18n = context.watch<UiI18n>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(i18n.tr('contact_page.title')),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            i18n.tr('contact_page.title'),
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(
            i18n.tr('contact_page.subtitle'),
            style: TextStyle(fontSize: 15, height: 1.45, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 20),
          _ChannelCard(
            icon: Icons.phone_outlined,
            title: i18n.tr('contact_page.phone_title'),
            desc: i18n.tr('contact_page.phone_desc'),
            links: [
              ('+856 20 55 516 658', Uri.parse('tel:+8562055516658')),
              ('+856 20 98 019 958', Uri.parse('tel:+8562098019958')),
            ],
            onOpen: _open,
          ),
          const SizedBox(height: 12),
          _ChannelCard(
            icon: Icons.chat_outlined,
            title: i18n.tr('contact_page.whatsapp_title'),
            desc: i18n.tr('contact_page.whatsapp_desc'),
            links: [
              ('+856 20 55 516 658', Uri.parse('https://wa.me/8562055516658')),
              ('+856 20 59 707 812', Uri.parse('https://wa.me/8562059707812')),
            ],
            onOpen: _open,
          ),
          const SizedBox(height: 12),
          _ChannelCard(
            icon: Icons.email_outlined,
            title: i18n.tr('contact_page.email_title'),
            desc: i18n.tr('contact_page.email_desc'),
            links: [
              ('khodthayofficial@gmail.com', Uri.parse('mailto:khodthayofficial@gmail.com')),
            ],
            onOpen: _open,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(Icons.access_time, i18n.tr('contact_page.hours_label'), i18n.tr('contact_page.hours_value')),
                  const SizedBox(height: 10),
                  _InfoRow(Icons.place_outlined, i18n.tr('contact_page.location_label'), i18n.tr('contact_page.location_value')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HelpCenterPage()),
            ),
            icon: const Icon(Icons.help_outline),
            label: Text(i18n.tr('contact_page.help_link')),
          ),
        ],
      ),
    );
  }
}

class _ChannelCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  final List<(String, Uri)> links;
  final Future<void> Function(Uri) onOpen;

  const _ChannelCard({
    required this.icon,
    required this.title,
    required this.desc,
    required this.links,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(desc, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
            const SizedBox(height: 12),
            for (final link in links)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: InkWell(
                  onTap: () => onOpen(link.$2),
                  child: Text(
                    link.$1,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.accent),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              Text(value, style: TextStyle(fontSize: 14, color: Colors.grey.shade800)),
            ],
          ),
        ),
      ],
    );
  }
}
