
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:laoepic_thesis_app/features/payment/pages/payment_return_page.dart';
import 'package:laoepic_thesis_app/core/api/api_locale_prefs.dart';
import 'package:laoepic_thesis_app/config/app_config.dart';
import 'package:laoepic_thesis_app/i18n/i18n_keys.dart';
import 'package:laoepic_thesis_app/i18n/ui_i18n.dart';
import 'package:laoepic_thesis_app/data/services/pending_payment.dart';
import 'package:laoepic_thesis_app/theme/app_colors.dart';
import 'package:laoepic_thesis_app/shared/utils/invoice_status.dart';
import 'package:laoepic_thesis_app/shared/utils/money_format.dart';
import 'package:laoepic_thesis_app/shared/utils/phajay_qr_image.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

/// In-app QR scan screen (parity with web `QrPaymentPanel`).
class PhajayQrPaymentPage extends StatefulWidget {
  final int bookingId;
  final String? invoiceNo;
  final Map<String, dynamic> qrPayload;
  final String currencyCode;

  const PhajayQrPaymentPage({
    super.key,
    required this.bookingId,
    required this.qrPayload,
    this.invoiceNo,
    this.currencyCode = 'LAK',
  });

  @override
  State<PhajayQrPaymentPage> createState() => _PhajayQrPaymentPageState();
}

class _PhajayQrPaymentPageState extends State<PhajayQrPaymentPage> {
  Timer? _timer;
  bool _paid = false;
  int _ticks = 0;

  @override
  void initState() {
    super.initState();
    _poll();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) => _poll());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _poll() async {
    if (_paid) return;
    _ticks++;
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null) return;

    try {
      final res = await http.get(
        Uri.parse('${AppConfig.baseUrl}/bookings/${widget.bookingId}'),
        headers: await buildAuthApiHeaders(token),
      );
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode != 200 || body['success'] != true) return;

      final booking = body['data'] as Map<String, dynamic>;
      final invoice = booking['invoice'] as Map<String, dynamic>?;
      final status = resolveInvoiceDisplayStatus(invoice, booking);

      if (status.paymentComplete && mounted) {
        await PendingPayment.clear();
        setState(() => _paid = true);
        _timer?.cancel();
        await Future<void>.delayed(const Duration(milliseconds: 800));
        if (!mounted) return;
        await Navigator.pushReplacement<void, void>(
          context,
          MaterialPageRoute<void>(
            builder: (_) => PaymentReturnPage(
              bookingId: widget.bookingId,
              invoiceNo: widget.invoiceNo,
            ),
          ),
        );
      }
    } catch (_) {
      if (_ticks > 40 && mounted) {
        _timer?.cancel();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final i18n = context.watch<UiI18n>();
    final qr = widget.qrPayload['qrCode']?.toString();
    final link = widget.qrPayload['link']?.toString();
    final amount = widget.qrPayload['amount'];
    final invoiceAmount = widget.qrPayload['invoiceAmount'];
    final walletCapped = widget.qrPayload['phajayWalletQrCapped'] == true;
    final bankCapped = widget.qrPayload['phajayBankQrCapped'] == true;
    final walletMax = widget.qrPayload['phajayWalletQrMax'];
    final bankMax = widget.qrPayload['phajayBankQrMax'];
    final currency = widget.currencyCode;

    final payLabel = MoneyFormat.format(amount, currency: currency);
    final invoiceLabel =
        invoiceAmount != null
            ? MoneyFormat.format(invoiceAmount, currency: currency)
            : null;

    final qrWidget = buildPhajayQrImage(qr, size: 260);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: Text(i18n.tr(I18nKey.paymentQrTitle)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  if (_paid)
                    const Icon(Icons.check_circle, color: Colors.green, size: 48)
                  else if (qrWidget != null)
                    qrWidget
                  else
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    payLabel,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  if ((walletCapped || bankCapped) && invoiceLabel != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      walletCapped
                          ? i18n.tr(
                            I18nKey.paymentQrWalletCap,
                            params: {
                              'pay': payLabel,
                              'invoice': invoiceLabel,
                              'max': '${walletMax ?? 1000}',
                            },
                          )
                          : i18n.tr(
                            I18nKey.paymentQrBankCap,
                            params: {
                              'pay': payLabel,
                              'invoice': invoiceLabel,
                              'max': '${bankMax ?? 999}',
                            },
                          ),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.amber.shade900,
                        height: 1.4,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    i18n.tr(I18nKey.paymentQrScanHint),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blueGrey.shade600,
                      height: 1.45,
                    ),
                  ),
                  if (!_paid) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          i18n.tr(I18nKey.paymentQrWaiting),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blueGrey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (link != null && link.isNotEmpty) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () async {
                  final uri = Uri.tryParse(link);
                  if (uri != null) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                icon: const Icon(Icons.open_in_browser),
                label: Text(i18n.tr(I18nKey.paymentQrOpenLink)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
