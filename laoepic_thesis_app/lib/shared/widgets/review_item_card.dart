
import 'package:flutter/material.dart';
import 'package:laoepic_thesis_app/config/app_config.dart';
import 'package:laoepic_thesis_app/i18n/i18n_keys.dart';
import 'package:laoepic_thesis_app/i18n/ui_i18n.dart';
import 'package:laoepic_thesis_app/data/services/reviews_api.dart';
import 'package:provider/provider.dart';

/// Review card — matches web `ReviewItem` (stars → quote → profile → activity bar).
class ReviewItemCard extends StatelessWidget {
  final PackageReview review;
  final String dateLabel;
  final VoidCallback? onActivityTap;

  const ReviewItemCard({
    super.key,
    required this.review,
    required this.dateLabel,
    this.onActivityTap,
  });

  static const Color _starColor = Color(0xFFFFC107);
  static const Color _starEmpty = Color(0xFFE5E7EB);

  @override
  Widget build(BuildContext context) {
    final i18n = context.watch<UiI18n>();
    final comment = (review.comment ?? '').trim();
    final activityTitle = (review.packageTitle ?? '').trim();
    final avatarUrl = review.reviewerAvatar?.trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120F172A),
            blurRadius: 24,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(5, (i) {
              final filled = i < review.rating;
              return Padding(
                padding: const EdgeInsets.only(right: 2),
                child: Icon(
                  Icons.star_rounded,
                  size: 20,
                  color: filled ? _starColor : _starEmpty,
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          Text(
            '“$comment”',
            style: const TextStyle(
              fontSize: 15,
              height: 1.65,
              fontStyle: FontStyle.italic,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFFFF4EC),
                backgroundImage:
                    avatarUrl != null && avatarUrl.isNotEmpty
                        ? NetworkImage(AppConfig.mediaUrl(avatarUrl))
                        : null,
                child:
                    avatarUrl == null || avatarUrl.isEmpty
                        ? const Icon(Icons.person, color: Color(0xFFF58A07))
                        : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.reviewerName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (activityTitle.isNotEmpty) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: onActivityTap,
                      child: Text(
                        activityTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0F000000),
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Text(
                      i18n.tr(I18nKey.packetReviewActivityTag),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF97316),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
