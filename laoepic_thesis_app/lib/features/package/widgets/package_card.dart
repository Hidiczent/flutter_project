
import 'package:flutter/material.dart';
import 'package:laoepic_thesis_app/features/package/pages/package_detail_page.dart';
import 'package:laoepic_thesis_app/data/models/package_model.dart';
import 'package:laoepic_thesis_app/providers/api_locale_provider.dart';
import 'package:laoepic_thesis_app/providers/price_display_provider.dart';
import 'package:laoepic_thesis_app/theme/app_colors.dart';
import 'package:laoepic_thesis_app/i18n/ui_i18n.dart';
import 'package:laoepic_thesis_app/shared/utils/package_display.dart';
import 'package:provider/provider.dart';

/// Compact card listing a tour package's image, title, price, and favorite toggle.
class PackageCard extends StatelessWidget {
  final PackageModel pkg;
  final bool fullWidth;

  const PackageCard({super.key, required this.pkg, this.fullWidth = false});

  @override
  Widget build(BuildContext context) {
    final locale = uiLocaleFromCode(context.read<ApiLocaleProvider>().code);
    final pdp = context.watch<PriceDisplayProvider>();
    final i18n = context.watch<UiI18n>();
    final subtitle = getPackageCardSubtitle(pkg, locale);
    final rawStatus = pkg.status.trim();
    final statusRawLower = rawStatus.toLowerCase();
    final status =
        statusRawLower.startsWith('package_status_')
            ? statusRawLower.substring('package_status_'.length)
            : statusRawLower;
    final statusKey = 'package.status.$status';
    final statusLabel = i18n.tr(statusKey);
    final badgeText =
        statusLabel == statusKey ? rawStatus : statusLabel;
    final badgeColor =
        status == 'active'
            ? Colors.green
            : status == 'draft'
            ? Colors.grey
            : status == 'pending_review'
            ? Colors.orange
            : status == 'inactive'
            ? Colors.red
            : Colors.black;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PackageDetailPage(packageId: pkg.id),
        ),
      ),
      child: Container(
        width: fullWidth ? double.infinity : 180,
        margin: EdgeInsets.symmetric(
          horizontal: fullWidth ? 0 : 8,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, 
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Stack(
                children: [
                  Image.network(
                    pkg.mainImageUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      'assets/images/default.jpg',
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (rawStatus.isNotEmpty)
                    Positioned(
                      left: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          badgeText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pkg.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.primary,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: Colors.black45),
                    ),
                  ],
                  if (pkg.durationDays != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      '${pkg.durationDays} day(s)',
                      style: const TextStyle(fontSize: 10, color: Colors.black38),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    pkg.about,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: List.generate(
                      5,
                      (_) => const Icon(Icons.star, color: Colors.amber, size: 16),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    pkg.displayPrice(pdp),
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
