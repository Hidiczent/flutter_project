import 'package:flutter/material.dart';
import 'package:laoepic_thesis_app/features/booking/pages/booking_page.dart';
import 'package:laoepic_thesis_app/i18n/i18n_keys.dart';
import 'package:laoepic_thesis_app/i18n/ui_i18n.dart';
import 'package:laoepic_thesis_app/data/models/package_model.dart';
import 'package:laoepic_thesis_app/providers/api_locale_provider.dart';
import 'package:laoepic_thesis_app/providers/price_display_provider.dart';
import 'package:laoepic_thesis_app/shared/utils/package_display.dart';
import 'package:laoepic_thesis_app/shared/utils/guide_display.dart';
import 'package:laoepic_thesis_app/features/package/widgets/package_guide_card.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:laoepic_thesis_app/shared/widgets/app_feedback.dart';

/// Package detail tab showing itinerary highlights, inclusions, and village information.
class AboutTab extends StatelessWidget {
  final PackageModel package;
  const AboutTab({super.key, required this.package});

  Widget _bullets(
    String title,
    List<String> items, {
    IconData icon = Icons.circle,
  }) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFF084887)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF084887),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...items.map((t) => BulletText(t)),
        ],
      ),
    );
  }

  Future<void> _openUrl(BuildContext context, String url) async {
    final u = Uri.tryParse(url);
    if (u == null) return;
    if (!await launchUrl(u, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        await AppFeedback.showError(
          context,
          message: context.read<UiI18n>().tr(
            I18nKey.aboutCouldNotOpen,
            params: {'url': url},
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final i18n = context.watch<UiI18n>();
    final p = package;
    final emDash = i18n.tr(I18nKey.commonEmDash);
    final location = getPackageDisplayLocation(
      p,
      uiLocaleFromCode(context.read<ApiLocaleProvider>().code),
    );
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            p.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF084887),
            ),
          ),
          if (location.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.place_outlined,
                  size: 18,
                  color: Colors.orange.shade700,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    location,
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ],
          if (p.resolvedLocale != null && p.resolvedLocale!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                i18n.tr(
                  I18nKey.aboutLocaleLine,
                  params: {'locale': p.resolvedLocale!},
                ),
                style: const TextStyle(fontSize: 12, color: Colors.black45),
              ),
            ),
          const SizedBox(height: 12),
          ExpansionTile(
            initiallyExpanded: true,
            tilePadding: EdgeInsets.zero,
            title: Text(
              i18n.tr(I18nKey.aboutDescription),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF084887),
              ),
            ),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  p.about.isEmpty ? emDash : p.about,
                  style: const TextStyle(fontSize: 15, height: 1.4),
                ),
              ),
            ],
          ),
          const Divider(),
          _bullets(
            i18n.tr(I18nKey.aboutGettingThere),
            p.gettingThere,
            icon: Icons.directions_walk,
          ),
          _bullets(
            i18n.tr(I18nKey.aboutActivities),
            p.activities,
            icon: Icons.hiking,
          ),
          _bullets(
            i18n.tr(I18nKey.aboutFeesExtras),
            p.fees,
            icon: Icons.payments_outlined,
          ),
          _bullets(
            i18n.tr(I18nKey.aboutFacilities),
            p.facilities,
            icon: Icons.checkroom_outlined,
          ),
          _bullets(
            i18n.tr(I18nKey.aboutOpeningHours),
            p.openingHours,
            icon: Icons.schedule,
          ),
          _bullets(
            i18n.tr(I18nKey.aboutTipsVisitors),
            p.tipsForVisitors,
            icon: Icons.lightbulb_outline,
          ),
          _bullets(
            i18n.tr(I18nKey.aboutMustBring),
            p.bringMustHave,
            icon: Icons.backpack,
          ),
          _bullets(
            i18n.tr(I18nKey.aboutOptionalBring),
            p.bringOptional,
            icon: Icons.add_circle_outline,
          ),
          if (p.socialLinks.isNotEmpty) ...[
            Text(
              i18n.tr(I18nKey.aboutSocial),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF084887),
              ),
            ),
            const SizedBox(height: 8),
            ...p.socialLinks.map(
              (s) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(_socialIcon(s.platform)),
                title: Text(s.platform),
                subtitle: Text(
                  s.url,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () => _openUrl(context, s.url),
              ),
            ),
          ],
          if (p.provider != null) ...[
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.business, color: Color(0xFF084887)),
                title: Text(i18n.tr(I18nKey.aboutProvider)),
                subtitle: Text(
                  [
                    p.provider!.providerName,
                    if (p.provider!.contactName != null &&
                        p.provider!.contactName!.isNotEmpty)
                      p.provider!.contactName!,
                    if (p.provider!.phone != null &&
                        p.provider!.phone!.isNotEmpty)
                      p.provider!.phone!,
                    if (p.provider!.email != null &&
                        p.provider!.email!.isNotEmpty)
                      p.provider!.email!,
                  ].join('\n'),
                ),
              ),
            ),
          ],
          if (mapGuideToCard(p.guide) != null) ...[
            const SizedBox(height: 12),
            Text(
              i18n.tr(I18nKey.aboutGuide),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF084887),
              ),
            ),
            const SizedBox(height: 10),
            PackageGuideCard(guide: mapGuideToCard(p.guide)!),
          ],
          const SizedBox(height: 24),
          Text(
            i18n.tr(I18nKey.aboutPriceFrom),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFF58A07),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            p.displayPrice(context.watch<PriceDisplayProvider>()),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF084887),
            ),
          ),
          if (p.durationDays != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                i18n.tr(
                  I18nKey.aboutSuggestedDuration,
                  params: {'days': '${p.durationDays}'},
                ),
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookingPage(packageId: p.id),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF084887),
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              i18n.tr(I18nKey.aboutBookNow),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xffffffff),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  IconData _socialIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'facebook':
        return Icons.facebook;
      case 'instagram':
        return Icons.camera_alt_outlined;
      case 'tiktok':
        return Icons.music_note;
      default:
        return Icons.link;
    }
  }
}

/// Simple bullet-list row widget used inside package about content.
class BulletText extends StatelessWidget {
  final String text;
  const BulletText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }
}
