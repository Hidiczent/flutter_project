
import 'package:flutter/material.dart';
import 'package:laoepic_thesis_app/i18n/i18n_keys.dart';
import 'package:laoepic_thesis_app/i18n/ui_i18n.dart';
import 'package:laoepic_thesis_app/data/models/package_model.dart';
import 'package:laoepic_thesis_app/providers/api_locale_provider.dart';
import 'package:laoepic_thesis_app/data/services/reviews_api.dart';
import 'package:laoepic_thesis_app/shared/utils/app_date_format.dart';
import 'package:laoepic_thesis_app/shared/widgets/review_item_card.dart';
import 'package:provider/provider.dart';

/// Expandable reviews block on a package page with average rating and recent comments.
class PackageReviewsSection extends StatefulWidget {
  final PackageModel package;

  const PackageReviewsSection({super.key, required this.package});

  @override
  State<PackageReviewsSection> createState() => _PackageReviewsSectionState();
}

class _PackageReviewsSectionState extends State<PackageReviewsSection> {
  List<PackageReview> _reviews = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await ReviewsApi.fetchByPackage(widget.package.id.toString());
    if (!mounted) return;
    setState(() {
      _reviews = list
          .where((r) => (r.comment ?? '').trim().isNotEmpty)
          .map(
            (r) => r.copyWith(
              packageTitle: r.packageTitle ?? widget.package.title,
            ),
          )
          .toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final i18n = context.watch<UiI18n>();
    final localeCode = context.read<ApiLocaleProvider>().code;

    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            i18n.tr(
              I18nKey.packetAllReviews,
              params: {'count': _reviews.length.toString()},
            ),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 16),
          if (_reviews.isEmpty)
            Text(
              i18n.tr(I18nKey.packetNoReviews),
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
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
                ),
              ),
            ),
        ],
      ),
    );
  }
}
