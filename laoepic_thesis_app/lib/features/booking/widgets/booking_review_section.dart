
import 'package:flutter/material.dart';
import 'package:laoepic_thesis_app/i18n/i18n_keys.dart';
import 'package:laoepic_thesis_app/i18n/ui_i18n.dart';
import 'package:laoepic_thesis_app/providers/api_locale_provider.dart';
import 'package:laoepic_thesis_app/theme/app_colors.dart';
import 'package:laoepic_thesis_app/shared/utils/app_date_format.dart';
import 'package:laoepic_thesis_app/shared/utils/booking_review_eligibility.dart';
import 'package:laoepic_thesis_app/features/booking/widgets/leave_review_sheet.dart';
import 'package:provider/provider.dart';

/// Review CTA / status — mirrors web `BookingReviewSection`.
class BookingReviewSection extends StatelessWidget {
  final Map<String, dynamic> booking;
  final VoidCallback? onReviewSubmitted;

  const BookingReviewSection({
    super.key,
    required this.booking,
    this.onReviewSubmitted,
  });

  int get _bookingId =>
      int.tryParse(booking['bookingId']?.toString() ?? '') ?? 0;

  int? get _packageId {
    final pkg = booking['package'] as Map<String, dynamic>?;
    final id = pkg?['packageId'] ?? pkg?['id'];
    return int.tryParse(id?.toString() ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final i18n = context.watch<UiI18n>();
    final localeCode = context.read<ApiLocaleProvider>().code;
    final existing = booking['review'] as Map<String, dynamic>?;

    if (existing != null) {
      final rating =
          int.tryParse(existing['rating']?.toString() ?? '') ?? 0;
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFFE082)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              i18n.tr(I18nKey.reviewSubmittedLabel),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFFE65100),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: List.generate(
                5,
                (i) => Icon(
                  i < rating ? Icons.star_rounded : Icons.star_border_rounded,
                  size: 18,
                  color: Colors.amber,
                ),
              ),
            ),
            if ((existing['comment']?.toString() ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                '"${existing['comment']}"',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, height: 1.4),
              ),
            ],
          ],
        ),
      );
    }

    final eligibility = getBookingReviewEligibility(booking);

    if (eligibility.reason == ReviewEligibilityReason.notConfirmed ||
        eligibility.reason == ReviewEligibilityReason.missingSchedule) {
      return const SizedBox.shrink();
    }

    if (eligibility.reason == ReviewEligibilityReason.windowClosed) {
      return Text(
        i18n.tr(I18nKey.reviewWindowClosed),
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      );
    }

    if (eligibility.reason == ReviewEligibilityReason.tourNotEnded) {
      final opensLabel = formatDateTimeLocalized(
        eligibility.opensAt,
        localeCode,
      );
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.schedule, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                opensLabel != '—'
                    ? i18n.tr(
                      I18nKey.reviewOpensAfterTrip,
                      params: {'date': opensLabel},
                    )
                    : i18n.tr(I18nKey.reviewOpensAfterTripGeneric),
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
            ),
          ],
        ),
      );
    }

    if (!eligibility.canReview) return const SizedBox.shrink();

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _bookingId <= 0
            ? null
            : () async {
              final ok = await showLeaveReviewSheet(
                context,
                bookingId: _bookingId,
                packageId: _packageId,
              );
              if (ok == true) onReviewSubmitted?.call();
            },
        icon: const Icon(Icons.rate_review_outlined, size: 20),
        label: Text(i18n.tr(I18nKey.reviewWriteTitle)),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}
