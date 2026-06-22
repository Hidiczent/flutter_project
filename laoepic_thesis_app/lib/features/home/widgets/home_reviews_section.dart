
import 'package:flutter/material.dart';
import 'package:laoepic_thesis_app/features/package/pages/package_detail_page.dart';
import 'package:laoepic_thesis_app/i18n/i18n_keys.dart';
import 'package:laoepic_thesis_app/i18n/ui_i18n.dart';
import 'package:laoepic_thesis_app/providers/api_locale_provider.dart';
import 'package:laoepic_thesis_app/data/services/reviews_api.dart';
import 'package:laoepic_thesis_app/theme/app_colors.dart';
import 'package:laoepic_thesis_app/shared/utils/app_date_format.dart';
import 'package:laoepic_thesis_app/shared/widgets/review_item_card.dart';
import 'package:provider/provider.dart';

/// Carousel of featured traveler reviews pulled from the reviews API.
class HomeReviewsSection extends StatefulWidget {
  final List<int> packageIds;
  final Map<int, String> packageTitles;

  const HomeReviewsSection({
    super.key,
    required this.packageIds,
    this.packageTitles = const {},
  });

  @override
  State<HomeReviewsSection> createState() => _HomeReviewsSectionState();
}

class _HomeReviewsSectionState extends State<HomeReviewsSection> {
  List<PackageReview> _reviews = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await ReviewsApi.fetchRecent(
      limit: 3,
      packageIds: widget.packageIds,
      packageTitles: widget.packageTitles,
    );
    if (mounted) {
      setState(() {
        _reviews = list;
        _loading = false;
      });
    }
  }

  void _openPackage(String packageId) {
    final id = int.tryParse(packageId);
    if (id == null || id <= 0) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PackageDetailPage(packageId: id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final i18n = context.watch<UiI18n>();
    final localeCode = context.read<ApiLocaleProvider>().code;

    if (!_loading && _reviews.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4EC),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.chat_bubble_outline, size: 14, color: AppColors.accent),
                    const SizedBox(width: 6),
                    Text(
                      i18n.tr(I18nKey.homeReviewsBadge).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
                        color: Color(0xFFF27C22),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                i18n.tr(I18nKey.homeReviewsTitle),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF003366),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  i18n.tr(I18nKey.homeReviewsSubtitle),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (_loading)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else
          ..._reviews.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ReviewItemCard(
                review: r,
                dateLabel: formatDateTimeLocalized(
                  r.createdAt,
                  localeCode,
                  dateOnly: true,
                ),
                onActivityTap:
                    r.packageId.isNotEmpty
                        ? () => _openPackage(r.packageId)
                        : null,
              ),
            ),
          ),
      ],
    );
  }
}
