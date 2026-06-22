
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:laoepic_thesis_app/features/booking/pages/booking_detail_page.dart';
import 'package:laoepic_thesis_app/features/booking/pages/invoice_page.dart';
import 'package:laoepic_thesis_app/core/api/api_locale_prefs.dart';
import 'package:laoepic_thesis_app/config/app_config.dart';
import 'package:laoepic_thesis_app/i18n/i18n_keys.dart';
import 'package:laoepic_thesis_app/i18n/ui_i18n.dart';
import 'package:laoepic_thesis_app/data/services/pending_payment.dart';
import 'package:laoepic_thesis_app/theme/app_colors.dart';
import 'package:laoepic_thesis_app/shared/utils/invoice_status.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PaymentReturnPhase { verifying, paid, failed, unknown }

/// Handles the return URL after PhaJay payment and polls until the invoice is settled.
class PaymentReturnPage extends StatefulWidget {
  final int bookingId;
  final String? invoiceNo;

  const PaymentReturnPage({
    super.key,
    required this.bookingId,
    this.invoiceNo,
  });

  @override
  State<PaymentReturnPage> createState() => _PaymentReturnPageState();
}

class _PaymentReturnPageState extends State<PaymentReturnPage> {
  PaymentReturnPhase _phase = PaymentReturnPhase.verifying;
  String? _packageTitle;
  Timer? _timer;
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
    _ticks++;
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null) {
      if (mounted) setState(() => _phase = PaymentReturnPhase.unknown);
      return;
    }
    try {
      final res = await http.get(
        Uri.parse('${AppConfig.baseUrl}/bookings/${widget.bookingId}'),
        headers: await buildAuthApiHeaders(token),
      );
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode != 200 || body['success'] != true) {
        if (mounted && _ticks > 8) {
          setState(() => _phase = PaymentReturnPhase.unknown);
        }
        return;
      }
      final booking = body['data'] as Map<String, dynamic>;
      final invoice = booking['invoice'] as Map<String, dynamic>?;
      final pkg = booking['package'] as Map<String, dynamic>?;
      final status = resolveInvoiceDisplayStatus(invoice, booking);

      if (status.paymentComplete) {
        await PendingPayment.clear();
        if (mounted) {
          setState(() {
            _phase = PaymentReturnPhase.paid;
            _packageTitle = pkg?['title']?.toString();
          });
        }
        _timer?.cancel();
        return;
      }

      final bookStatus = booking['status']?.toString().toLowerCase() ?? '';
      if (bookStatus == 'cancelled' || bookStatus == 'expired') {
        await PendingPayment.clear();
        if (mounted) setState(() => _phase = PaymentReturnPhase.failed);
        _timer?.cancel();
        return;
      }

      if (_ticks > 45 && mounted) {
        setState(() => _phase = PaymentReturnPhase.unknown);
        _timer?.cancel();
      }
    } catch (_) {
      if (_ticks > 12 && mounted) {
        setState(() => _phase = PaymentReturnPhase.unknown);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final i18n = context.watch<UiI18n>();
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: Text(i18n.tr(I18nKey.paymentReturnTitle)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _buildBody(i18n),
      ),
    );
  }

  Widget _buildBody(UiI18n i18n) {
    switch (_phase) {
      case PaymentReturnPhase.verifying:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              i18n.tr(I18nKey.paymentReturnVerifyingTitle),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              i18n.tr(I18nKey.paymentReturnVerifyingDesc),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        );
      case PaymentReturnPhase.paid:
        return _resultCard(
          i18n,
          icon: Icons.check_circle,
          color: Colors.green,
          title: i18n.tr(I18nKey.paymentReturnSuccessTitle),
          desc: i18n.tr(I18nKey.paymentReturnSuccessDesc),
        );
      case PaymentReturnPhase.failed:
        return _resultCard(
          i18n,
          icon: Icons.cancel,
          color: Colors.red,
          title: i18n.tr(I18nKey.paymentReturnFailedTitle),
          desc: i18n.tr(I18nKey.paymentReturnFailedDesc),
        );
      case PaymentReturnPhase.unknown:
        return _resultCard(
          i18n,
          icon: Icons.help_outline,
          color: Colors.orange,
          title: i18n.tr(I18nKey.paymentReturnUnknownTitle),
          desc: i18n.tr(I18nKey.paymentReturnUnknownDesc),
        );
    }
  }

  Widget _resultCard(
    UiI18n i18n, {
    required IconData icon,
    required Color color,
    required String title,
    required String desc,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 72, color: color),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        if (_packageTitle != null && _packageTitle!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(_packageTitle!, textAlign: TextAlign.center),
        ],
        const SizedBox(height: 12),
        Text(
          desc,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => InvoicePage(bookingId: widget.bookingId),
                ),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text(i18n.tr(I18nKey.invoiceViewFull)),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => BookingDetailPage(orderId: widget.bookingId),
                ),
              );
            },
            child: Text(i18n.tr(I18nKey.paymentReturnViewBooking)),
          ),
        ),
      ],
    );
  }
}
