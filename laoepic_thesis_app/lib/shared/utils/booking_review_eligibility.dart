/// Post-tour review eligibility rules aligned with web and backend.
library;

/// Number of days after tour end during which a review may be submitted.
const int reviewWindowDaysAfterTour = 60;

/// Machine-readable reason why review submission is allowed or blocked.
enum ReviewEligibilityReason {
  eligible,
  notConfirmed,
  alreadyReviewed,
  tourNotEnded,
  windowClosed,
  missingSchedule,
}

/// Result of evaluating whether the customer can leave a review.
class ReviewEligibility {
  final bool canReview;
  final ReviewEligibilityReason reason;
  final String? opensAt;
  final String? closesAt;

  const ReviewEligibility({
    required this.canReview,
    required this.reason,
    this.opensAt,
    this.closesAt,
  });
}

/// Computes tour end time from schedule fields on a booking payload.
DateTime? resolveTourEndAt({
  String? departureDatetime,
  String? returnDatetime,
  int? durationDays,
}) {
  if (returnDatetime != null && returnDatetime.isNotEmpty) {
    final end = DateTime.tryParse(returnDatetime);
    if (end != null) return end;
  }
  if (departureDatetime == null || departureDatetime.isEmpty) return null;
  final departure = DateTime.tryParse(departureDatetime);
  if (departure == null) return null;
  final days = (durationDays ?? 1).clamp(1, 365);
  return departure.add(Duration(days: days));
}

/// Evaluates review eligibility from booking status and schedule timestamps.
ReviewEligibility getReviewEligibility({
  required String status,
  required bool hasReview,
  String? departureDatetime,
  String? returnDatetime,
  int? durationDays,
  DateTime? now,
}) {
  final clock = now ?? DateTime.now();

  if (hasReview) {
    return const ReviewEligibility(
      canReview: false,
      reason: ReviewEligibilityReason.alreadyReviewed,
    );
  }

  if (status.toLowerCase() != 'confirmed') {
    return const ReviewEligibility(
      canReview: false,
      reason: ReviewEligibilityReason.notConfirmed,
    );
  }

  final tourEndAt = resolveTourEndAt(
    departureDatetime: departureDatetime,
    returnDatetime: returnDatetime,
    durationDays: durationDays,
  );

  if (tourEndAt == null) {
    return const ReviewEligibility(
      canReview: false,
      reason: ReviewEligibilityReason.missingSchedule,
    );
  }

  final opensAt = tourEndAt.toUtc().toIso8601String();
  final closesAt = tourEndAt
      .add(const Duration(days: reviewWindowDaysAfterTour))
      .toUtc()
      .toIso8601String();

  if (clock.isBefore(tourEndAt)) {
    return ReviewEligibility(
      canReview: false,
      reason: ReviewEligibilityReason.tourNotEnded,
      opensAt: opensAt,
      closesAt: closesAt,
    );
  }

  final closes = DateTime.tryParse(closesAt);
  if (closes != null && clock.isAfter(closes)) {
    return ReviewEligibility(
      canReview: false,
      reason: ReviewEligibilityReason.windowClosed,
      opensAt: opensAt,
      closesAt: closesAt,
    );
  }

  return ReviewEligibility(
    canReview: true,
    reason: ReviewEligibilityReason.eligible,
    opensAt: opensAt,
    closesAt: closesAt,
  );
}

/// Reads `reviewEligibility` from API JSON when present, otherwise computes locally.
ReviewEligibility getBookingReviewEligibility(Map<String, dynamic> booking) {
  final fromApi = booking['reviewEligibility'] as Map<String, dynamic>?;
  if (fromApi != null) {
    final reasonRaw = fromApi['reason']?.toString() ?? 'eligible';
    ReviewEligibilityReason reason;
    switch (reasonRaw) {
      case 'not_confirmed':
        reason = ReviewEligibilityReason.notConfirmed;
      case 'already_reviewed':
        reason = ReviewEligibilityReason.alreadyReviewed;
      case 'tour_not_ended':
        reason = ReviewEligibilityReason.tourNotEnded;
      case 'window_closed':
        reason = ReviewEligibilityReason.windowClosed;
      case 'missing_schedule':
        reason = ReviewEligibilityReason.missingSchedule;
      default:
        reason = ReviewEligibilityReason.eligible;
    }
    return ReviewEligibility(
      canReview: fromApi['canReview'] == true,
      reason: reason,
      opensAt: fromApi['opensAt']?.toString(),
      closesAt: fromApi['closesAt']?.toString(),
    );
  }

  final pkg = booking['package'] as Map<String, dynamic>?;
  final durationDays = int.tryParse(pkg?['durationDays']?.toString() ?? '');

  return getReviewEligibility(
    status: booking['status']?.toString() ?? '',
    hasReview: booking['review'] != null,
    departureDatetime: booking['departureDatetime']?.toString(),
    returnDatetime: booking['returnDatetime']?.toString(),
    durationDays: durationDays,
  );
}

/// Whether the customer may cancel this booking according to `cancelEligibility`.
bool canCancelBooking(Map<String, dynamic> booking) {
  final eligibility = booking['cancelEligibility'] as Map<String, dynamic>?;
  if (eligibility == null) return false;
  if (eligibility['cancellationPending'] == true) return false;
  return eligibility['canCancel'] == true;
}

/// Returns `instant` or `request` cancel mode from the booking payload.
String? cancelMode(Map<String, dynamic> booking) {
  final eligibility = booking['cancelEligibility'] as Map<String, dynamic>?;
  return eligibility?['cancelMode']?.toString();
}
