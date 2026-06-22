
import 'package:shared_preferences/shared_preferences.dart';

/// Persists in-flight payment context locally so return URLs can resume the right booking.
class PendingPayment {
  final int bookingId;
  final String? invoiceNo;

  const PendingPayment({required this.bookingId, this.invoiceNo});

  static const _keyBooking = 'pending_payment_booking_id';
  static const _keyInvoice = 'pending_payment_invoice_no';

  /// Save for this module.
  static Future<void> save({
    required int bookingId,
    String? invoiceNo,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyBooking, bookingId);
    if (invoiceNo != null && invoiceNo.isNotEmpty) {
      await prefs.setString(_keyInvoice, invoiceNo);
    } else {
      await prefs.remove(_keyInvoice);
    }
  }
  /// Loads  and notifies listeners.
  static Future<PendingPayment?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt(_keyBooking);
    if (id == null) return null;
    return PendingPayment(
      bookingId: id,
      invoiceNo: prefs.getString(_keyInvoice),
    );
  }

  /// Clear for this module.
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyBooking);
    await prefs.remove(_keyInvoice);
  }
}
