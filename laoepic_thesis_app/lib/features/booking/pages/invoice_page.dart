
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:laoepic_thesis_app/core/api/api_locale_prefs.dart';
import 'package:laoepic_thesis_app/config/app_config.dart';
import 'package:laoepic_thesis_app/i18n/i18n_keys.dart';
import 'package:laoepic_thesis_app/i18n/ui_i18n.dart';
import 'package:laoepic_thesis_app/data/models/package_model.dart';
import 'package:laoepic_thesis_app/providers/api_locale_provider.dart';
import 'package:laoepic_thesis_app/theme/app_colors.dart';
import 'package:laoepic_thesis_app/shared/utils/invoice_status.dart';
import 'package:laoepic_thesis_app/shared/utils/package_display.dart';
import 'package:laoepic_thesis_app/shared/utils/guide_display.dart';
import 'package:http/http.dart' as http;
import 'package:laoepic_thesis_app/shared/utils/app_date_format.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:laoepic_thesis_app/data/models/invoice_pdf_data.dart';
import 'package:laoepic_thesis_app/data/services/invoice_pdf_builder.dart';
import 'package:laoepic_thesis_app/shared/widgets/app_feedback.dart';
import 'package:printing/printing.dart';
import 'package:laoepic_thesis_app/shared/utils/money_format.dart';
import 'package:laoepic_thesis_app/data/services/phajay_payment_navigator.dart';
import 'package:laoepic_thesis_app/data/services/phajay_payment_service.dart';

/// Displays a booking invoice with download and share actions for the traveler.
class InvoicePage extends StatefulWidget {
  final int bookingId;

  const InvoicePage({super.key, required this.bookingId});

  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  Map<String, dynamic>? _booking;
  PackageModel? _package;
  bool _loading = true;
  bool _pdfLoading = false;
  String? _error;
  String _payBank = 'bcel';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null) {
      setState(() {
        _loading = false;
        _error = 'not_logged_in';
      });
      return;
    }
    try {
      final bookingRes = await http.get(
        Uri.parse('${AppConfig.baseUrl}/bookings/${widget.bookingId}'),
        headers: await buildAuthApiHeaders(token),
      );
      final bookingBody = jsonDecode(bookingRes.body) as Map<String, dynamic>;
      if (bookingRes.statusCode != 200 || bookingBody['success'] != true) {
        throw Exception('booking');
      }
      final booking = Map<String, dynamic>.from(
        bookingBody['data'] as Map<String, dynamic>,
      );

      Map<String, dynamic>? invoice =
          booking['invoice'] as Map<String, dynamic>?;
      if (invoice == null) {
        final createRes = await http.post(
          Uri.parse(
            '${AppConfig.baseUrl}/invoices/from-booking/${widget.bookingId}',
          ),
          headers: await buildAuthApiHeaders(token),
        );
        if (createRes.statusCode == 200 || createRes.statusCode == 201) {
          final cBody = jsonDecode(createRes.body) as Map<String, dynamic>;
          invoice = cBody['data'] as Map<String, dynamic>?;
        } else {
          final getRes = await http.get(
            Uri.parse(
              '${AppConfig.baseUrl}/invoices/by-booking/${widget.bookingId}',
            ),
            headers: await buildAuthApiHeaders(token),
          );
          if (getRes.statusCode == 200) {
            final gBody = jsonDecode(getRes.body) as Map<String, dynamic>;
            invoice = gBody['data'] as Map<String, dynamic>?;
          }
        }
        if (invoice != null) booking['invoice'] = invoice;
      }

      PackageModel? pkg;
      final pkgRaw = booking['package'] as Map<String, dynamic>?;
      final pkgId = pkgRaw?['packageId'] ?? pkgRaw?['id'];
      if (pkgId != null) {
        final pkgRes = await http.get(
          Uri.parse('${AppConfig.baseUrl}/packages/$pkgId'),
          headers: await buildPublicApiHeaders(),
        );
        if (pkgRes.statusCode == 200) {
          final pBody = jsonDecode(pkgRes.body) as Map<String, dynamic>;
          final data = pBody['data'];
          if (data is Map<String, dynamic>) {
            pkg = PackageModel.fromJson(data);
          }
        }
      }
      if (pkg == null && pkgRaw != null) {
        try {
          pkg = PackageModel.fromJson(pkgRaw);
        } catch (_) {}
      }

      if (!mounted) return;
      setState(() {
        _booking = booking;
        _package = pkg;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'load_failed';
      });
    }
  }

  String _formatDt(String? iso, String localeCode) {
    return formatDateTimeLocalized(iso, localeCode);
  }

  Future<void> _payNow(Map<String, dynamic> invoice, {String bank = 'bcel'}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null) return;
    final invoiceId = invoice['invoiceId']?.toString();
    if (invoiceId == null || invoiceId.isEmpty) return;

    final invoiceNo = invoice['invoiceNo']?.toString();
    final currency =
        _booking?['currencyCode']?.toString() ??
        invoice['currencyCode']?.toString() ??
        'LAK';

    if (!mounted) return;
    await PhajayPaymentNavigator.start(
      context: context,
      token: token,
      bookingId: widget.bookingId,
      invoiceId: invoiceId,
      invoiceNo: invoiceNo,
      bank: bank,
      currencyCode: currency,
    );
    await _load();
  }

  InvoicePdfData _pdfData(UiI18n i18n, UiLocale uiLocale, String localeCode) {
    final booking = _booking!;
    final invoice = booking['invoice'] as Map<String, dynamic>?;
    final pkg = _package;
    final status = resolveInvoiceDisplayStatus(invoice, booking);
    final passengers = booking['passengers'] as List<dynamic>? ?? [];
    final peopleCount =
        booking['peopleCount'] is int
            ? booking['peopleCount'] as int
            : int.tryParse('${booking['peopleCount']}') ?? passengers.length;

    final contactName =
        passengers.isNotEmpty
            ? (passengers.first as Map)['fullName']?.toString() ?? '—'
            : '—';
    final pkgTitle =
        pkg?.title ?? booking['package']?['title']?.toString() ?? '—';
    final location =
        pkg != null ? getPackageDisplayLocation(pkg, uiLocale) : '';

    final currency = booking['currencyCode']?.toString();
    final subtotalRaw = invoice?['subtotal'] ?? booking['totalAmount'];
    final taxRaw = invoice?['taxAmount'] ?? '0';
    final grandRaw = invoice?['grandTotal'] ?? booking['totalAmount'];
    final subtotal = MoneyFormat.format(subtotalRaw, currency: currency);
    final tax = MoneyFormat.format(taxRaw, currency: currency);
    final grand = MoneyFormat.format(grandRaw, currency: currency);

    final travelerNames =
        passengers.isEmpty
            ? [i18n.tr(I18nKey.invoiceNoTravelers)]
            : passengers
                .map((p) => (p as Map)['fullName']?.toString() ?? '')
                .where((n) => n.isNotEmpty)
                .toList();

    return InvoicePdfData(
      activityLabel: i18n.tr(I18nKey.invoiceActivityTitle),
      invoiceHeading: i18n.tr(I18nKey.invoiceHeading),
      invoiceNo: invoice?['invoiceNo']?.toString() ?? '',
      statusLabel: i18n.tr(status.labelKey),
      paidNote:
          status.paymentComplete ? i18n.tr(I18nKey.invoiceAlreadyPaid) : '',
      packageTitle: pkgTitle,
      location: location,
      customerLabel: i18n.tr(I18nKey.invoiceCustomer),
      customerName: contactName,
      bookingIdLabel: i18n.tr(I18nKey.invoiceBookingId),
      bookingId: '${widget.bookingId}',
      bookingStatusLabel: i18n.tr(I18nKey.invoiceBookingStatus),
      bookingStatus: i18n.tr(status.labelKey),
      travelersLabel: i18n.tr(I18nKey.invoiceTravelersCount),
      travelersSummary: i18n.tr(
        I18nKey.invoiceTravelersLine,
        params: {'count': '$peopleCount'},
      ),
      departureLabel: i18n.tr(I18nKey.invoiceDeparture),
      departure:
          booking['departureDatetime'] != null
              ? _formatDt(booking['departureDatetime']?.toString(), localeCode)
              : '',
      dateLabel: i18n.tr(I18nKey.invoiceDate),
      issueDate:
          invoice?['issueDate'] != null
              ? _formatDt(invoice!['issueDate']?.toString(), localeCode)
              : '',
      travelersSection: i18n.tr(I18nKey.invoiceTravelersSection),
      nameColumn: i18n.tr(I18nKey.invoiceTravelerName),
      travelerNames: travelerNames,
      subtotalLabel: i18n.tr(I18nKey.invoiceSubtotal),
      subtotal: subtotal,
      taxLabel: i18n.tr(I18nKey.invoiceTax),
      tax: tax,
      grandTotalLabel: i18n.tr(I18nKey.invoiceGrandTotal),
      grandTotal: grand,
    );
  }

  Future<void> _downloadPdf(
    UiI18n i18n,
    UiLocale uiLocale,
    String localeCode,
  ) async {
    if (_booking == null) return;
    setState(() => _pdfLoading = true);
    try {
      final doc = await InvoicePdfBuilder.build(
        _pdfData(i18n, uiLocale, localeCode),
        context: context,
        localeCode: localeCode,
      );
      final bytes = await doc.save();
      final invoice = _booking!['invoice'] as Map<String, dynamic>?;
      final rawName = invoice?['invoiceNo']?.toString() ?? 'invoice';
      final safeName = '${rawName.replaceAll(RegExp(r'[^\w.\-]+'), '_')}.pdf';
      await Printing.sharePdf(bytes: bytes, filename: safeName);
    } catch (_) {
      if (mounted) {
        await AppFeedback.showError(
          context,
          message: i18n.tr(I18nKey.invoicePdfError),
        );
      }
    } finally {
      if (mounted) setState(() => _pdfLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final i18n = context.watch<UiI18n>();
    final localeCode = context.read<ApiLocaleProvider>().code;
    final uiLocale = uiLocaleFromCode(localeCode);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: Text(i18n.tr(I18nKey.invoiceTitle)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          if (_error == null && !_loading)
            IconButton(
              onPressed:
                  _pdfLoading
                      ? null
                      : () => _downloadPdf(i18n, uiLocale, localeCode),
              icon:
                  _pdfLoading
                      ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : const Icon(Icons.download_rounded),
              tooltip: i18n.tr(I18nKey.invoiceDownloadPdf),
            ),
        ],
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(child: Text(i18n.tr(I18nKey.invoiceLoadFailed)))
              : _buildBody(i18n, uiLocale, localeCode),
    );
  }

  Widget _buildBody(UiI18n i18n, UiLocale uiLocale, String localeCode) {
    final booking = _booking!;
    final invoice = booking['invoice'] as Map<String, dynamic>?;
    final pkg = _package;
    final status = resolveInvoiceDisplayStatus(invoice, booking);
    final passengers = booking['passengers'] as List<dynamic>? ?? [];
    final peopleCount =
        booking['peopleCount'] is int
            ? booking['peopleCount'] as int
            : int.tryParse('${booking['peopleCount']}') ?? passengers.length;

    final contactName =
        passengers.isNotEmpty
            ? (passengers.first as Map)['fullName']?.toString() ?? '—'
            : '—';
    final pkgTitle =
        pkg?.title ?? booking['package']?['title']?.toString() ?? '—';
    final location =
        pkg != null ? getPackageDisplayLocation(pkg, uiLocale) : '';
    final bookingPkg = booking['package'] as Map<String, dynamic>?;
    final guide = guideFromJsonMap(bookingPkg) ?? pkg?.guide;

    final currency = booking['currencyCode']?.toString();
    final subtotalRaw = invoice?['subtotal'] ?? booking['totalAmount'];
    final taxRaw = invoice?['taxAmount'] ?? '0';
    final grandRaw = invoice?['grandTotal'] ?? booking['totalAmount'];
    final subtotal = MoneyFormat.format(subtotalRaw, currency: currency);
    final tax = MoneyFormat.format(taxRaw, currency: currency);
    final grand = MoneyFormat.format(grandRaw, currency: currency);

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (status.paymentComplete)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                border: Border.all(color: Colors.green.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green.shade700,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      i18n.tr(I18nKey.invoiceAlreadyPaid),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    i18n.tr(I18nKey.invoiceHeading),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                  if (invoice?['invoiceNo'] != null)
                    Text(
                      invoice!['invoiceNo'].toString(),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    pkgTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF004C8C),
                    ),
                  ),
                  if (location.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.place,
                            color: Colors.orange.shade700,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Expanded(child: Text(location)),
                        ],
                      ),
                    ),
                  if (guide != null && guide.fullName.trim().isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text(
                      i18n.tr(I18nKey.invoiceGuideDetail),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF084887),
                      ),
                    ),
                    const SizedBox(height: 6),
                    _metaRow(
                      i18n.tr(I18nKey.invoiceGuideName),
                      guide.fullName,
                    ),
                    if (guide.phone != null && guide.phone!.trim().isNotEmpty)
                      _metaRow(
                        i18n.tr(I18nKey.invoiceGuidePhone),
                        guide.phone!.trim(),
                      ),
                    if (guide.email != null && guide.email!.trim().isNotEmpty)
                      _metaRow(
                        i18n.tr(I18nKey.invoiceGuideEmail),
                        guide.email!.trim(),
                      ),
                  ],
                  const SizedBox(height: 12),
                  Text(
                    '${i18n.tr(I18nKey.invoiceCustomer)}: $contactName',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const Divider(height: 24),
                  _metaRow(
                    i18n.tr(I18nKey.invoiceBookingId),
                    '${widget.bookingId}',
                  ),
                  _metaRow(
                    i18n.tr(I18nKey.invoiceBookingStatus),
                    i18n.tr(status.labelKey),
                  ),
                  _metaRow(
                    i18n.tr(I18nKey.invoiceTravelersCount),
                    i18n.tr(
                      I18nKey.invoiceTravelersLine,
                      params: {'count': '$peopleCount'},
                    ),
                  ),
                  if (booking['departureDatetime'] != null)
                    _metaRow(
                      i18n.tr(I18nKey.invoiceDeparture),
                      _formatDt(
                        booking['departureDatetime']?.toString(),
                        localeCode,
                      ),
                    ),
                  if (invoice?['issueDate'] != null)
                    _metaRow(
                      i18n.tr(I18nKey.invoiceDate),
                      _formatDt(invoice!['issueDate']?.toString(), localeCode),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    i18n.tr(I18nKey.invoiceTravelersSection),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (passengers.isEmpty)
                    Text(i18n.tr(I18nKey.invoiceNoTravelers))
                  else
                    ...List.generate(passengers.length, (i) {
                      final p = passengers[i] as Map<String, dynamic>;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Text(
                              '${i + 1}.',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                p['fullName']?.toString() ?? 'Guest ${i + 1}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _totalRow(i18n.tr(I18nKey.invoiceSubtotal), subtotal),
                  _totalRow(i18n.tr(I18nKey.invoiceTax), tax),
                  const Divider(),
                  _totalRow(
                    i18n.tr(I18nKey.invoiceGrandTotal),
                    grand,
                    bold: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed:
                  _pdfLoading
                      ? null
                      : () => _downloadPdf(i18n, uiLocale, localeCode),
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: Text(
                _pdfLoading
                    ? i18n.tr(I18nKey.invoiceDownloadingPdf)
                    : i18n.tr(I18nKey.invoiceDownloadPdf),
              ),
            ),
          ),
          if (!status.paymentComplete && invoice != null) ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _payBank,
              decoration: const InputDecoration(
                labelText: 'Bank / M-Money',
                border: OutlineInputBorder(),
              ),
              items: PhajayPaymentService.qrBanks
                  .map(
                    (b) => DropdownMenuItem(
                      value: b,
                      child: Text(b == 'm_money' ? 'M-Money' : b.toUpperCase()),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _payBank = v);
              },
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => _payNow(invoice, bank: _payBank),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(i18n.tr(I18nKey.invoicePayNow)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _metaRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    ),
  );

  Widget _totalRow(String label, String value, {bool bold = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: bold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: bold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}
