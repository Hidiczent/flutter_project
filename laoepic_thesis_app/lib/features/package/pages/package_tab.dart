
import 'package:flutter/material.dart';
import 'package:laoepic_thesis_app/features/booking/pages/booking_page.dart';
import 'package:laoepic_thesis_app/i18n/i18n_keys.dart';
import 'package:laoepic_thesis_app/i18n/ui_i18n.dart';
import 'package:provider/provider.dart';
import 'package:laoepic_thesis_app/data/models/package_model.dart';
import 'package:laoepic_thesis_app/providers/price_display_provider.dart';
import 'package:laoepic_thesis_app/features/package/widgets/package_reviews_section.dart';

/// Overview tab on a package detail page with gallery, pricing, and review preview.
class PackageTab extends StatelessWidget {
  final PackageModel package;
  const PackageTab({super.key, required this.package});

  @override
  Widget build(BuildContext context) {
    final i18n = context.watch<UiI18n>();
    final pdp = context.watch<PriceDisplayProvider>();
    final p = package;
    final facilities = p.facilities;
    final previewList = facilities.isNotEmpty ? facilities : p.activities;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  p.displayPrice(pdp),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF084887),
                  ),
                ),
                if (p.packageType != null) ...[
                  const SizedBox(height: 4),
                  Chip(
                    label: Text(
                      i18n.tr(
                        I18nKey.packetType,
                        params: {'name': p.packageType!.typeName},
                      ),
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
                if (p.durationDays != null)
                  Text(
                    i18n.tr(
                      I18nKey.packetDuration,
                      params: {'days': '${p.durationDays}'},
                    ),
                  ),
                if (p.location != null && p.location!.isNotEmpty)
                  Text(
                    p.location!,
                    style: const TextStyle(color: Colors.black87, fontSize: 14),
                  ),
                if (p.provider != null)
                  Text(
                    i18n.tr(
                      I18nKey.packetProvider,
                      params: {'name': p.provider!.providerName},
                    ),
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                if (p.guide != null)
                  Text(
                    i18n.tr(
                      I18nKey.packetGuide,
                      params: {'name': p.guide!.fullName},
                    ),
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
              ],
            ),
          ),
          if (p.gallery.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                i18n.tr(I18nKey.packetGallery),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF084887),
                ),
              ),
            ),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: p.gallery.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final g = p.gallery[i];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: AspectRatio(
                      aspectRatio: 1.2,
                      child: Image.network(
                        g.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) => Image.asset(
                              'assets/images/default.jpg',
                              fit: BoxFit.cover,
                            ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],

          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  i18n.tr(I18nKey.packetOverview),
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.teal.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    p.about.isEmpty ? i18n.tr(I18nKey.commonEmDash) : p.about,
                    maxLines: 6,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF084887),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => BookingPage(packageId: p.id),
                        ),
                      );
                    },
                    child: Text(
                      i18n.tr(I18nKey.packetBookNow),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              color: Colors.blueGrey[50],
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    previewList.isEmpty
                        ? i18n.tr(I18nKey.packetHighlights)
                        : (facilities.isNotEmpty
                            ? i18n.tr(I18nKey.packetFacilities)
                            : i18n.tr(I18nKey.packetActivities)),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (previewList.isEmpty)
                    Text(
                      i18n.tr(I18nKey.packetPreviewHint),
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    )
                  else
                    ...previewList.map((line) => InclusionItem(line, true)),
                ],
              ),
            ),
          ),
          PackageReviewsSection(package: p),
        ],
      ),
    );
  }
}

/// Circular icon tile representing an included service on a package overview.
class ServiceIcon extends StatelessWidget {
  final String label;
  final IconData icon;

  const ServiceIcon({required this.label, required this.icon, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: Colors.teal[50],
          child: Icon(icon, color: Colors.teal),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

/// Row showing a single included or excluded item with a check or cross icon.
class InclusionItem extends StatelessWidget {
  final String text;
  final bool included;

  const InclusionItem(this.text, this.included, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          included ? Icons.check_circle : Icons.cancel,
          color: included ? Colors.teal : Colors.red,
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }
}
