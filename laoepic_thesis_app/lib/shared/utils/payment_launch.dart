
import 'package:flutter/material.dart';
import 'package:laoepic_thesis_app/features/payment/pages/payment_return_page.dart';
import 'package:laoepic_thesis_app/data/services/pending_payment.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens PhaJay in the browser, then shows [PaymentReturnPage] to poll status.
Future<bool> launchPaymentAndShowReturn({
  required BuildContext context,
  required int bookingId,
  required String redirectUrl,
  String? invoiceNo,
}) async {
  await PendingPayment.save(bookingId: bookingId, invoiceNo: invoiceNo);
  final uri = Uri.tryParse(redirectUrl);
  if (uri == null ||
      !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    await PendingPayment.clear();
    return false;
  }
  if (!context.mounted) return true;
  await Navigator.push<void>(
    context,
    MaterialPageRoute<void>(
      builder: (_) => PaymentReturnPage(
        bookingId: bookingId,
        invoiceNo: invoiceNo,
      ),
    ),
  );
  return true;
}
