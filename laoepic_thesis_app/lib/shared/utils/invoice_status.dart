/// Invoice and booking payment status labels for Flutter UI.
/// Mirrors the customer web helper `invoiceDisplayStatus.ts`.
library;

/// UI-facing payment status: i18n label key plus whether payment is complete.
class InvoiceDisplayStatus {
  /// Translation key under `invoice.*` for the status label.
  final String labelKey;

  /// `true` when the customer should see payment as completed.
  final bool paymentComplete;

  const InvoiceDisplayStatus({
    required this.labelKey,
    required this.paymentComplete,
  });
}

/// Derives a display status from raw invoice and booking JSON from the API.
///
/// Combines invoice status, booking status, and optional payment verification
/// state into a single label suitable for invoice and payment screens.
InvoiceDisplayStatus resolveInvoiceDisplayStatus(
  Map<String, dynamic>? invoice,
  Map<String, dynamic>? booking,
) {
  final inv = invoice?['status']?.toString().toLowerCase() ?? '';
  final book = booking?['status']?.toString().toLowerCase() ?? '';
  final pay = (invoice?['payment'] as Map<String, dynamic>?)?['verifyStatus']
      ?.toString()
      .toLowerCase();

  if (inv == 'paid' || book == 'confirmed') {
    return InvoiceDisplayStatus(
      labelKey: book == 'confirmed'
          ? 'invoice.status_confirmed'
          : 'invoice.status_paid',
      paymentComplete: true,
    );
  }
  if (pay == 'verified' || book == 'paid') {
    return InvoiceDisplayStatus(
      labelKey: book == 'paid'
          ? 'invoice.status_booking_paid'
          : 'invoice.status_paid',
      paymentComplete: true,
    );
  }
  if (inv == 'void') {
    return const InvoiceDisplayStatus(
      labelKey: 'invoice.status_void',
      paymentComplete: false,
    );
  }
  if (pay == 'pending') {
    return const InvoiceDisplayStatus(
      labelKey: 'invoice.status_payment_pending',
      paymentComplete: false,
    );
  }
  return const InvoiceDisplayStatus(
    labelKey: 'invoice.status_awaiting_payment',
    paymentComplete: false,
  );
}
