
import 'package:laoepic_thesis_app/shared/utils/money_format.dart';

/// Data model for booking history model parsed from API JSON.
class BookingHistoryModel {
  final int orderId;
  final String packageTitle;
  final String location;
  final double price;
  final String currencyCode;
  final String departureIso;
  final String status;
  final int points;
  final int peopleCount;
  final String lifecycleHint;
  final String cancelMode;
  final bool cancellationPending;
  final String cancelHint;
  final bool apiCanCancel;
  /// Full booking JSON from API (for review / cancel eligibility widgets).
  final Map<String, dynamic> sourceJson;

  BookingHistoryModel({
    required this.orderId,
    required this.packageTitle,
    required this.location,
    required this.price,
    this.currencyCode = 'LAK',
    required this.departureIso,
    required this.status,
    required this.points,
    required this.peopleCount,
    this.lifecycleHint = '',
    this.cancelMode = 'none',
    this.cancellationPending = false,
    this.cancelHint = '',
    this.apiCanCancel = false,
    required this.sourceJson,
  });

  factory BookingHistoryModel.fromJson(Map<String, dynamic> json) {
    final bookingId = int.tryParse(json['bookingId']?.toString() ?? '') ?? 0;
    final pkg = json['package'] as Map<String, dynamic>?;
    final lifecycle = json['lifecycle'] as Map<String, dynamic>?;
    final eligibility = json['cancelEligibility'] as Map<String, dynamic>?;
    final title = pkg?['title']?.toString() ?? 'Package';
    final loc = pkg?['location']?.toString() ?? '';
    final price =
        double.tryParse(json['totalAmount']?.toString() ?? '0') ?? 0.0;
    final cur = MoneyFormat.normalizeCurrency(json['currencyCode']?.toString());
    final dep =
        json['departureDatetime']?.toString() ??
        json['bookingDate']?.toString() ??
        '';

    final cancelMode = eligibility?['cancelMode']?.toString() ?? 'none';
    final cancellationPending = eligibility?['cancellationPending'] == true;
    final cancelHint = eligibility?['hint']?.toString() ?? '';
    final apiCanCancel =
        eligibility?['canCancel'] == true && !cancellationPending;

    return BookingHistoryModel(
      orderId: bookingId,
      packageTitle: title,
      location: loc,
      price: price,
      currencyCode: cur,
      departureIso: dep,
      status: json['status']?.toString() ?? '',
      points: 0,
      peopleCount: int.tryParse(json['peopleCount']?.toString() ?? '') ?? 1,
      lifecycleHint: lifecycle?['hint']?.toString() ?? '',
      cancelMode: cancelMode,
      cancellationPending: cancellationPending,
      cancelHint: cancelHint,
      apiCanCancel: apiCanCancel,
      sourceJson: json,
    );
  }

  bool get needsPayment => status.toLowerCase() == 'pending';

  /// Trust backend `cancelEligibility.canCancel` (includes lead-time rules).
  bool get canCancel => apiCanCancel;

  bool get isRequestCancel => cancelMode == 'request';
}
