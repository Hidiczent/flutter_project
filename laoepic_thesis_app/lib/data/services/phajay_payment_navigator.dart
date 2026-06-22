
import 'package:flutter/material.dart';
import 'package:laoepic_thesis_app/features/payment/pages/phajay_qr_payment_page.dart';
import 'package:laoepic_thesis_app/data/services/pending_payment.dart';
import 'package:laoepic_thesis_app/data/services/phajay_payment_service.dart';
import 'package:laoepic_thesis_app/shared/utils/payment_launch.dart';

/// Starts PhaJay payment: QR in-app (per bank / M-Money) or payment-link fallback.
class PhajayPaymentNavigator {
  /// Start for this module.
  static Future<bool> start({
    required BuildContext context,
    required String token,
    required int bookingId,
    required String invoiceId,
    String? invoiceNo,
    String bank = 'bcel',
    String currencyCode = 'LAK',
  }) async {
    await PendingPayment.save(bookingId: bookingId, invoiceNo: invoiceNo);

    final qrData = await PhajayPaymentService.createPaymentQr(
      token: token,
      invoiceId: invoiceId,
      bank: bank,
    );

    final qrCode = qrData?['qrCode']?.toString();
    if (qrCode != null && qrCode.isNotEmpty && context.mounted) {
      await Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (_) => PhajayQrPaymentPage(
            bookingId: bookingId,
            invoiceNo: invoiceNo,
            qrPayload: qrData!,
            currencyCode: currencyCode,
          ),
        ),
      );
      return true;
    }

    final linkData = await PhajayPaymentService.createPaymentLink(
      token: token,
      invoiceId: invoiceId,
    );
    final redirect = linkData?['redirectURL']?.toString();
    if (redirect == null || redirect.isEmpty) {
      await PendingPayment.clear();
      return false;
    }

    if (!context.mounted) return false;
    return launchPaymentAndShowReturn(
      context: context,
      bookingId: bookingId,
      redirectUrl: redirect,
      invoiceNo: invoiceNo,
    );
  }
}
