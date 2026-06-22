
import 'package:flutter/material.dart';
import 'package:laoepic_thesis_app/i18n/i18n_keys.dart';
import 'package:laoepic_thesis_app/i18n/ui_i18n.dart';
import 'package:laoepic_thesis_app/data/services/reviews_api.dart';
import 'package:laoepic_thesis_app/theme/app_colors.dart';
import 'package:laoepic_thesis_app/shared/widgets/app_feedback.dart';
import 'package:provider/provider.dart';

/// Opens a bottom sheet so the traveler can rate and review a completed tour.
Future<bool?> showLeaveReviewSheet(
  BuildContext context, {
  required int bookingId,
  int? packageId,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(ctx).viewInsets.bottom,
      ),
      child: LeaveReviewSheet(
        bookingId: bookingId,
        packageId: packageId,
      ),
    ),
  );
}

/// Bottom-sheet form for star rating and written feedback on a finished booking.
class LeaveReviewSheet extends StatefulWidget {
  final int bookingId;
  final int? packageId;

  const LeaveReviewSheet({
    super.key,
    required this.bookingId,
    this.packageId,
  });

  @override
  State<LeaveReviewSheet> createState() => _LeaveReviewSheetState();
}

class _LeaveReviewSheetState extends State<LeaveReviewSheet> {
  int _rating = 0;
  final _commentController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final i18n = context.read<UiI18n>();
    if (_rating < 1) {
      await AppFeedback.showWarning(
        context,
        message: i18n.tr(I18nKey.reviewRatingRequired),
      );
      return;
    }
    if (_commentController.text.trim().isEmpty) {
      await AppFeedback.showWarning(
        context,
        message: i18n.tr(I18nKey.reviewCommentRequired),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await ReviewsApi.create(
        bookingId: widget.bookingId,
        rating: _rating,
        comment: _commentController.text.trim(),
      );
      if (!mounted) return;
      await AppFeedback.showSuccess(
        context,
        message: i18n.tr(I18nKey.reviewSuccessText),
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      await AppFeedback.showError(
        context,
        message: e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final i18n = context.watch<UiI18n>();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              i18n.tr(I18nKey.reviewWriteTitle),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final star = i + 1;
                return IconButton(
                  onPressed: () => setState(() => _rating = star),
                  icon: Icon(
                    star <= _rating ? Icons.star_rounded : Icons.star_border_rounded,
                    color: Colors.amber,
                    size: 36,
                  ),
                );
              }),
            ),
            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: i18n.tr(I18nKey.reviewCommentHint),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _submitting
                  ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                  : Text(i18n.tr(I18nKey.reviewSubmit)),
            ),
          ],
        ),
      ),
    );
  }
}
