
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:laoepic_thesis_app/core/api/api_locale_prefs.dart';
import 'package:laoepic_thesis_app/config/app_config.dart';
import 'package:laoepic_thesis_app/i18n/i18n_keys.dart';
import 'package:laoepic_thesis_app/i18n/ui_i18n.dart';
import 'package:laoepic_thesis_app/theme/app_colors.dart';
import 'package:laoepic_thesis_app/features/booking/pages/invoice_page.dart';
import 'package:laoepic_thesis_app/shared/widgets/app_feedback.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:laoepic_thesis_app/shared/utils/money_format.dart';
import 'package:laoepic_thesis_app/shared/utils/booking_review_eligibility.dart';
import 'package:laoepic_thesis_app/data/services/phajay_payment_navigator.dart';
import 'package:laoepic_thesis_app/data/services/phajay_payment_service.dart';
import 'package:laoepic_thesis_app/features/booking/widgets/booking_review_section.dart';
import 'package:laoepic_thesis_app/features/booking/widgets/cancel_booking_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

/// Full booking summary with status, passengers, payment info, and actions like cancel or review.
class BookingDetailPage extends StatefulWidget {
  final int orderId;

  const BookingDetailPage({super.key, required this.orderId});

  @override
  State<BookingDetailPage> createState() => _BookingDetailPageState();
}

class _BookingDetailPageState extends State<BookingDetailPage>
    with WidgetsBindingObserver {
  Map<String, dynamic>? _booking;
  String? _error;
  bool _loading = true;
  bool _paying = false;
  String _payBank = 'bcel';

  final ScrollController _scrollController = ScrollController();
  final GlobalKey _keyStatus = GlobalKey();
  final GlobalKey _keyPackage = GlobalKey();
  final GlobalKey _keyTrip = GlobalKey();
  final GlobalKey _keyPay = GlobalKey();
  final GlobalKey _keyInvoice = GlobalKey();
  final GlobalKey _keyVoucher = GlobalKey();
  final GlobalKey _keyCancel = GlobalKey();
  final GlobalKey _keyReview = GlobalKey();
  final GlobalKey _keyPeople = GlobalKey();
  final GlobalKey _keyMeta = GlobalKey();

  int get _bookingId => widget.orderId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetch();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _scrollToSection(GlobalKey key) async {
    final ctx = key.currentContext;
    if (ctx == null) return;
    await Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
      alignment: 0.06,
    );
  }

  Future<void> _fetch() async {
    final initial = _booking == null;
    if (initial) {
      setState(() {
        _loading = true;
        _error = null;
      });
    } else {
      setState(() => _error = null);
    }
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final i18n = context.read<UiI18n>();
    final token = prefs.getString('jwt_token');
    if (token == null) {
      setState(() {
        _loading = false;
        _error = i18n.tr(I18nKey.bookingDetailPleaseSignIn);
      });
      return;
    }
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/bookings/$_bookingId'),
        headers: await buildAuthApiHeaders(token),
      );
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 && body['success'] == true) {
        if (mounted) {
          setState(() {
            _booking = body['data'] as Map<String, dynamic>?;
            _error = null;
            _loading = false;
          });
        }
      } else {
        final msg =
            body['message']?.toString() ??
            i18n.tr(I18nKey.bookingDetailFailedLoad);
        if (mounted) {
          setState(() {
            if (initial) _error = msg;
            _loading = false;
          });
          if (!initial) {
            final parsed = AppFeedback.parseApiMessage(response.body);
            await AppFeedback.showError(
              context,
              message: parsed.isNotEmpty ? parsed : msg,
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          if (initial) _error = e.toString();
          _loading = false;
        });
        if (!initial) {
          await AppFeedback.showError(
            context,
            message: i18n.tr(
              I18nKey.bookingDetailRefreshFailed,
              params: {'error': e.toString()},
            ),
          );
        }
      }
    }
  }

  String _str(UiI18n i18n, dynamic v) {
    if (v == null) return i18n.tr(I18nKey.commonEmDash);
    final s = v.toString().trim();
    return s.isEmpty ? i18n.tr(I18nKey.commonEmDash) : s;
  }

  String _fmt(UiI18n i18n, String? iso) {
    if (iso == null || iso.isEmpty) return i18n.tr(I18nKey.commonEmDash);
    try {
      return DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(iso).toLocal());
    } catch (_) {
      return iso;
    }
  }

  String _fmtDateOnly(UiI18n i18n, String? iso) {
    if (iso == null || iso.isEmpty) return i18n.tr(I18nKey.commonEmDash);
    try {
      return DateFormat('dd/MM/yyyy').format(DateTime.parse(iso).toLocal());
    } catch (_) {
      return iso;
    }
  }

  String _money(UiI18n i18n, dynamic amount, String? currency) {
    if (amount == null || amount.toString().trim().isEmpty) {
      return i18n.tr(I18nKey.commonEmDash);
    }
    return MoneyFormat.format(amount, currency: currency);
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return const Color(0xFF2E7D32);
      case 'paid':
        return const Color(0xFF1565C0);
      case 'pending':
        return AppColors.accent;
      case 'cancelled':
        return const Color(0xFFC62828);
      case 'expired':
      case 'failed':
        return Colors.blueGrey.shade700;
      default:
        return Colors.blueGrey;
    }
  }

  String _statusLabel(UiI18n i18n, String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return i18n.tr(I18nKey.bookingDetailStatusPending);
      case 'paid':
        return i18n.tr(I18nKey.bookingDetailStatusPaid);
      case 'confirmed':
        return i18n.tr(I18nKey.bookingDetailStatusConfirmed);
      case 'cancelled':
        return i18n.tr(I18nKey.bookingDetailStatusCancelled);
      case 'expired':
        return i18n.tr(I18nKey.bookingDetailStatusExpired);
      case 'failed':
        return i18n.tr(I18nKey.bookingDetailStatusFailed);
      default:
        return status;
    }
  }

  Future<void> _openUrl(String? raw) async {
    final i18n = context.read<UiI18n>();
    if (raw == null || raw.trim().isEmpty) return;
    final url = AppConfig.mediaUrl(raw.trim());
    final uri = Uri.tryParse(url);
    if (uri == null) {
      if (mounted) {
        await AppFeedback.showError(
          context,
          message: i18n.tr(I18nKey.bookingDetailInvalidLink, params: {'url': url}),
        );
      }
      return;
    }
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
        mounted) {
      await AppFeedback.showError(
        context,
        message: i18n.tr(I18nKey.bookingDetailCouldNotOpenLink, params: {'url': url}),
      );
    }
  }

  Future<void> _openPhajay() async {
    final i18n = context.read<UiI18n>();
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null || _booking == null) return;

    setState(() => _paying = true);
    try {
      String? invoiceId =
          (_booking!['invoice'] as Map<String, dynamic>?)?['invoiceId']
              ?.toString();

      if (invoiceId == null || invoiceId.isEmpty) {
        final invRes = await http.post(
          Uri.parse(
            '${AppConfig.baseUrl}/invoices/from-booking/$_bookingId',
          ),
          headers: {
            ...await buildAuthApiHeaders(token),
            'Content-Type': 'application/json',
          },
        );
        var invBody = jsonDecode(invRes.body) as Map<String, dynamic>;
        if (invRes.statusCode == 201 && invBody['success'] == true) {
          final invData = invBody['data'] as Map<String, dynamic>?;
          invoiceId = invData?['invoiceId']?.toString();
        } else if (invBody['message']?.toString().contains('already exists') ==
            true) {
          final getInv = await http.get(
            Uri.parse(
              '${AppConfig.baseUrl}/invoices/by-booking/$_bookingId',
            ),
            headers: await buildAuthApiHeaders(token),
          );
          if (getInv.statusCode == 200) {
            invBody = jsonDecode(getInv.body) as Map<String, dynamic>;
            final invData = invBody['data'] as Map<String, dynamic>?;
            invoiceId = invData?['invoiceId']?.toString();
          }
        }
        if (invoiceId == null || invoiceId.isEmpty) {
          if (mounted) {
            final invMsg =
                AppFeedback.parseApiMessage(jsonEncode(invBody));
            await AppFeedback.showError(
              context,
              message: invMsg.isNotEmpty
                  ? invMsg
                  : (invBody['message']?.toString() ??
                      i18n.tr(I18nKey.bookingDetailCouldNotCreateInvoice)),
            );
          }
          return;
        }
      }

      final invoice = _booking?['invoice'] as Map<String, dynamic>?;
      final invoiceNo = invoice?['invoiceNo']?.toString();
      final currency =
          _booking?['currencyCode']?.toString() ??
          invoice?['currencyCode']?.toString() ??
          'LAK';

      if (mounted) {
        final opened = await PhajayPaymentNavigator.start(
          context: context,
          token: token,
          bookingId: _bookingId,
          invoiceId: invoiceId,
          invoiceNo: invoiceNo,
          bank: _payBank,
          currencyCode: currency,
        );
        if (!opened) {
          await AppFeedback.showError(
            context,
            message: i18n.tr(I18nKey.bookingDetailNoPaymentUrl),
          );
        }
      }
      await _fetch();
    } catch (e) {
      if (mounted) {
        await AppFeedback.showError(
          context,
          message: i18n.tr(
            I18nKey.bookingDetailRefreshFailed,
            params: {'error': e.toString()},
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  bool _canPay(Map<String, dynamic> b) {
    final status = b['status']?.toString() ?? '';
    if (status != 'pending') return false;
    final inv = b['invoice'] as Map<String, dynamic>?;
    if (inv == null) return true;
    if (inv['status']?.toString() == 'paid') return false;
    final pay = inv['payment'] as Map<String, dynamic>?;
    if (pay != null && pay['verifyStatus']?.toString() == 'verified') {
      return false;
    }
    return true;
  }

  String? _refundStatusLabel(UiI18n i18n, Map<String, dynamic> b) {
    final refund = b['refund'] as Map<String, dynamic>?;
    if (refund == null) return null;
    final status = refund['refundStatus']?.toString() ?? 'none';
    if (status == 'none') return null;
    final statusLo = switch (status) {
      'pending_manual' => i18n.tr(I18nKey.bookingDetailRefundPending),
      'completed' => i18n.tr(I18nKey.bookingDetailRefundCompleted),
      'declined' => i18n.tr(I18nKey.bookingDetailRefundDeclined),
      _ => status,
    };
    final note = refund['refundNote']?.toString().trim();
    if (note != null && note.isNotEmpty) {
      return '$statusLo\n$note';
    }
    return statusLo;
  }

  List<_NavChip> _navChips(
    UiI18n i18n, {
    required bool hasPackage,
    required bool hasInvoice,
    required bool hasVoucher,
    required bool hasCancellation,
    required bool hasReview,
  }) {
    return [
      _NavChip(i18n.tr(I18nKey.bookingDetailNavOverview), _keyStatus),
      if (hasPackage) _NavChip(i18n.tr(I18nKey.bookingDetailNavPackage), _keyPackage),
      _NavChip(i18n.tr(I18nKey.bookingDetailNavDates), _keyTrip),
      _NavChip(i18n.tr(I18nKey.bookingDetailNavPay), _keyPay),
      if (hasInvoice) _NavChip(i18n.tr(I18nKey.bookingDetailNavInvoice), _keyInvoice),
      if (hasVoucher) _NavChip(i18n.tr(I18nKey.bookingDetailNavVoucher), _keyVoucher),
      if (hasCancellation) _NavChip(i18n.tr(I18nKey.bookingDetailNavCancelled), _keyCancel),
      if (hasReview) _NavChip(i18n.tr(I18nKey.bookingDetailNavReview), _keyReview),
      _NavChip(i18n.tr(I18nKey.bookingDetailNavGuests), _keyPeople),
      _NavChip(i18n.tr(I18nKey.bookingDetailNavSystem), _keyMeta),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final i18n = context.watch<UiI18n>();

    if (_loading && _booking == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF4F6F9),
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          title: Text(i18n.tr(I18nKey.bookingDetailTitle)),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                i18n.tr(I18nKey.commonLoading),
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null && _booking == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF4F6F9),
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          title: Text(i18n.tr(I18nKey.bookingDetailTitle)),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 56, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _fetch,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.refresh),
                  label: Text(i18n.tr(I18nKey.commonTryAgain)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final b = _booking!;
    final pkg = b['package'] as Map<String, dynamic>?;
    final inv = b['invoice'] as Map<String, dynamic>?;
    final passengers = b['passengers'] as List<dynamic>? ?? [];
    final cust = b['customer'] as Map<String, dynamic>?;
    final voucher = b['voucher'] as Map<String, dynamic>?;
    final cancellation = b['cancellation'] as Map<String, dynamic>?;
    final review = b['review'] as Map<String, dynamic>?;
    final reviewEligibility = getBookingReviewEligibility(b);
    final showCancelAction = canCancelBooking(b);
    final cancelModeStr = cancelMode(b) ?? 'none';
    final lifecycle = b['lifecycle'] as Map<String, dynamic>?;
    final statusStr = b['status']?.toString() ?? '';
    final statusColor = _statusColor(statusStr);
    final ed = i18n.tr(I18nKey.commonEmDash);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        scrolledUnderElevation: 1,
        foregroundColor: Colors.white,
        title: Text(
          i18n.tr(I18nKey.bookingDetailTitle),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: i18n.tr(I18nKey.commonRefresh),
            onPressed: _fetch,
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _fetch,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              sliver: SliverToBoxAdapter(
                child: KeyedSubtree(
                  key: _keyStatus,
                  child: _StatusHeader(
                    i18n: i18n,
                    bookingId: _str(i18n, b['bookingId']),
                    statusLabel: _statusLabel(i18n, statusStr),
                    statusColor: statusColor,
                    lifecycleHint: lifecycle != null ? _str(i18n, lifecycle['hint']) : null,
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 14)),
            SliverPersistentHeader(
              pinned: true,
              delegate: _BookingQuickNavDelegate(
                height: 50,
                entries: _navChips(
                  i18n,
                  hasPackage: pkg != null,
                  hasInvoice: inv != null,
                  hasVoucher: voucher != null,
                  hasCancellation: cancellation != null,
                  hasReview: review != null || reviewEligibility.canReview,
                ),
                onSelect: _scrollToSection,
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (pkg != null)
                    KeyedSubtree(
                      key: _keyPackage,
                      child: _SectionCard(
                      icon: Icons.tour_outlined,
                      title: i18n.tr(I18nKey.bookingDetailSectionPackage),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _str(i18n, pkg['title']),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1A2332),
                            ),
                          ),
                          if (_str(i18n, pkg['location']) != ed) ...[
                            const SizedBox(height: 6),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.place_outlined,
                                  size: 18,
                                  color: AppColors.primary.withOpacity(0.85),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    _str(i18n, pkg['location']),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: const Color(0xFF5C6B7A),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (_str(i18n, pkg['description']) != ed) ...[
                            const SizedBox(height: 10),
                            _ExpandablePlainText(
                              text: _str(i18n, pkg['description']),
                              style: theme.textTheme.bodySmall?.copyWith(
                                height: 1.45,
                                color: const Color(0xFF5C6B7A),
                              ),
                            ),
                          ],
                          _PackageExtrasExpansion(pkg: pkg, i18n: i18n),
                      ],
                    ),
                  ),
                  ),
                  const SizedBox(height: 12),
                  KeyedSubtree(
                    key: _keyTrip,
                    child: _SectionCard(
                      icon: Icons.event_available_outlined,
                    title: i18n.tr(I18nKey.bookingDetailSectionTravelDates),
                    child: Column(
                      children: [
                        _InfoRow(
                          icon: Icons.flight_takeoff_outlined,
                          label: i18n.tr(I18nKey.bookingDetailLabelDeparture),
                          value: _fmt(i18n, b['departureDatetime']?.toString()),
                        ),
                        _InfoRow(
                          icon: Icons.flight_land_outlined,
                          label: i18n.tr(I18nKey.bookingDetailLabelReturn),
                          value: _fmt(i18n, b['returnDatetime']?.toString()),
                        ),
                        _InfoRow(
                          icon: Icons.calendar_today_outlined,
                          label: i18n.tr(I18nKey.bookingDetailLabelBookedOn),
                          value: _fmtDateOnly(i18n, b['bookingDate']?.toString()),
                        ),
                        _InfoRow(
                          icon: Icons.groups_2_outlined,
                          label: i18n.tr(I18nKey.bookingDetailLabelPassengers),
                          value: _str(i18n, b['peopleCount']),
                        ),
                        if (_str(i18n, b['expiresAt']) != ed)
                          _InfoRow(
                            icon: Icons.timer_outlined,
                            label: i18n.tr(I18nKey.bookingDetailLabelPayBefore),
                            value: _fmt(i18n, b['expiresAt']?.toString()),
                            valueColor: AppColors.accent,
                          ),
                      ],
                    ),
                  ),
                  ),
                  const SizedBox(height: 12),
                  KeyedSubtree(
                    key: _keyPay,
                    child: _SectionCard(
                      icon: Icons.payments_outlined,
                    title: i18n.tr(I18nKey.bookingDetailSectionPayment),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _money(i18n, b['totalAmount'], b['currencyCode']?.toString()),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                        if (_canPay(b)) ...[
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: _payBank,
                            decoration: InputDecoration(
                              labelText: i18n.tr(I18nKey.bookingFormPayBank),
                              isDense: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            items: PhajayPaymentService.qrBanks
                                .map(
                                  (bank) => DropdownMenuItem(
                                    value: bank,
                                    child: Text(
                                      bank == 'm_money'
                                          ? 'M-Money'
                                          : bank.toUpperCase(),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: _paying
                                ? null
                                : (v) {
                                  if (v != null) {
                                    setState(() => _payBank = v);
                                  }
                                },
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: _paying ? null : _openPhajay,
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.accent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child:
                                  _paying
                                      ? const SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                      : Text(
                                        i18n.tr(I18nKey.bookingDetailPayWithPhajay),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  ),
                  if (inv != null) ...[
                    const SizedBox(height: 12),
                    KeyedSubtree(
                      key: _keyInvoice,
                      child: _SectionCard(
                      icon: Icons.receipt_long_outlined,
                      title: i18n.tr(I18nKey.bookingDetailSectionInvoice),
                      child: Column(
                        children: [
                          _InfoRow(
                            icon: Icons.tag_outlined,
                            label: i18n.tr(I18nKey.bookingDetailLabelNumber),
                            value: _str(i18n, inv['invoiceNo']),
                          ),
                          _InfoRow(
                            icon: Icons.flag_outlined,
                            label: i18n.tr(I18nKey.bookingDetailLabelInvoiceStatus),
                            value: _str(i18n, inv['status']),
                          ),
                          _InfoRow(
                            icon: Icons.account_balance_wallet_outlined,
                            label: i18n.tr(I18nKey.bookingDetailLabelGrandTotal),
                            value: _money(i18n, inv['grandTotal'], b['currencyCode']?.toString()),
                          ),
                          if (inv['payment'] != null) ...[
                            const Divider(height: 20),
                            _InfoRow(
                              icon: Icons.verified_outlined,
                              label: i18n.tr(I18nKey.bookingDetailLabelPaymentDetails),
                              value:
                                  '${_str(i18n, (inv['payment'] as Map)['verifyStatus'])} · ${_str(i18n, (inv['payment'] as Map)['method'])}',
                            ),
                          ],
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => InvoicePage(
                                      bookingId: _bookingId,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.receipt_long),
                              label: Text(i18n.tr(I18nKey.invoiceViewFull)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ),
                  ],
                  if (voucher != null) ...[
                    const SizedBox(height: 12),
                    KeyedSubtree(
                      key: _keyVoucher,
                      child: _SectionCard(
                      icon: Icons.card_giftcard_outlined,
                      title: i18n.tr(I18nKey.bookingDetailSectionVoucher),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _InfoRow(
                            icon: Icons.confirmation_number_outlined,
                            label: i18n.tr(I18nKey.bookingDetailLabelNumber),
                            value: _str(i18n, voucher['voucherNo']),
                          ),
                          _InfoRow(
                            icon: Icons.info_outline,
                            label: i18n.tr(I18nKey.bookingDetailLabelStatus),
                            value: _str(i18n, voucher['status']),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              if (_str(i18n, voucher['qrCodeUrl']) != ed)
                                OutlinedButton.icon(
                                  onPressed: () => _openUrl(voucher['qrCodeUrl']?.toString()),
                                  icon: const Icon(Icons.qr_code_2, size: 20),
                                  label: Text(i18n.tr(I18nKey.bookingDetailQr)),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.primary,
                                  ),
                                ),
                              if (_str(i18n, voucher['pdfUrl']) != ed)
                                OutlinedButton.icon(
                                  onPressed: () => _openUrl(voucher['pdfUrl']?.toString()),
                                  icon: const Icon(Icons.picture_as_pdf_outlined, size: 20),
                                  label: Text(i18n.tr(I18nKey.bookingDetailPdf)),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.primary,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    ),
                  ],
                  if (cancellation != null) ...[
                    const SizedBox(height: 12),
                    KeyedSubtree(
                      key: _keyCancel,
                      child: _SectionCard(
                      icon: Icons.cancel_outlined,
                      title: i18n.tr(I18nKey.bookingDetailSectionCancellation),
                      accent: const Color(0xFFC62828),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _InfoRow(
                            icon: Icons.pending_actions_outlined,
                            label: i18n.tr(I18nKey.bookingDetailLabelRequestStatus),
                            value: _str(i18n, cancellation['status']),
                          ),
                          if (_str(i18n, cancellation['reason']) != ed)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: _ExpandablePlainText(
                                text: cancellation['reason'].toString(),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  height: 1.4,
                                  color: const Color(0xFF5C6B7A),
                                ),
                                maxCollapsedLines: 3,
                              ),
                            ),
                        ],
                      ),
                    ),
                    ),
                  ],
                  if (_refundStatusLabel(i18n, b) != null) ...[
                    const SizedBox(height: 12),
                    _SectionCard(
                      icon: Icons.currency_exchange_outlined,
                      title: i18n.tr(
                        I18nKey.bookingDetailRefundTitle,
                        fallback: 'Refund status',
                      ),
                      accent: Colors.amber.shade800,
                      child: Text(
                        _refundStatusLabel(i18n, b)!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.45,
                          color: Colors.brown.shade800,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  KeyedSubtree(
                    key: _keyReview,
                    child: _SectionCard(
                      icon: Icons.rate_review_outlined,
                      title: i18n.tr(I18nKey.bookingDetailSectionYourReview),
                      child: BookingReviewSection(
                        booking: b,
                        onReviewSubmitted: _fetch,
                      ),
                    ),
                  ),
                  if (showCancelAction) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => showCancelBookingDialog(
                          context,
                          bookingId: _bookingId,
                          isRequestCancel: cancelModeStr == 'request',
                          onSuccess: _fetch,
                        ),
                        icon: Icon(Icons.cancel_outlined, color: Colors.red.shade400),
                        label: Text(
                          cancelModeStr == 'instant'
                              ? i18n.tr(I18nKey.bookingDetailCancelNow)
                              : i18n.tr(I18nKey.historyCancel),
                          style: TextStyle(color: Colors.red.shade400),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: Colors.red.shade200),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  KeyedSubtree(
                    key: _keyPeople,
                    child: _SectionCard(
                    icon: Icons.person_outline,
                    title: i18n.tr(I18nKey.bookingDetailSectionBookerPassengers),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (cust != null) ...[
                          _InfoRow(
                            icon: Icons.badge_outlined,
                            label: i18n.tr(I18nKey.bookingDetailLabelName),
                            value: _str(i18n, cust['fullName']),
                          ),
                          _InfoRow(
                            icon: Icons.email_outlined,
                            label: i18n.tr(I18nKey.bookingDetailLabelEmail),
                            value: _str(i18n, cust['email']),
                          ),
                          _InfoRow(
                            icon: Icons.phone_outlined,
                            label: i18n.tr(I18nKey.bookingDetailLabelPhone),
                            value: _str(i18n, cust['phone']),
                          ),
                          const Divider(height: 24),
                        ],
                        Text(
                          i18n.tr(
                            I18nKey.bookingDetailPassengersCount,
                            params: {'count': '${passengers.length}'},
                          ),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (passengers.isEmpty)
                          Text(
                            i18n.tr(I18nKey.bookingDetailNoPassengersOnFile),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.black45,
                            ),
                          )
                        else
                          _PassengerCollapsibleList(
                            passengers: passengers,
                            theme: theme,
                            i18n: i18n,
                          ),
                        if (_str(i18n, b['note']) != ed) ...[
                          const SizedBox(height: 14),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.accentSurface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.accent.withOpacity(0.25),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.sticky_note_2_outlined,
                                      size: 18,
                                      color: AppColors.accent,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      i18n.tr(I18nKey.bookingDetailNote),
                                      style: theme.textTheme.labelLarge?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  b['note'].toString(),
                                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  ),
                  const SizedBox(height: 12),
                  KeyedSubtree(
                    key: _keyMeta,
                    child: _SectionCard(
                    icon: Icons.info_outline,
                    title: i18n.tr(I18nKey.bookingDetailSectionSystem),
                    child: Column(
                      children: [
                        _InfoRow(
                          icon: Icons.numbers,
                          label: i18n.tr(I18nKey.bookingDetailLabelScheduleId),
                          value: _str(i18n, b['scheduleId']),
                        ),
                        _InfoRow(
                          icon: Icons.update_outlined,
                          label: i18n.tr(I18nKey.bookingDetailLabelCreated),
                          value: _fmt(i18n, b['createdAt']?.toString()),
                        ),
                        _InfoRow(
                          icon: Icons.edit_calendar_outlined,
                          label: i18n.tr(I18nKey.bookingDetailLabelLastUpdated),
                          value: _fmt(i18n, b['updatedAt']?.toString()),
                        ),
                        if (pkg != null && _str(i18n, pkg['resolvedLocale']) != ed)
                          _InfoRow(
                            icon: Icons.language_outlined,
                            label: i18n.tr(I18nKey.bookingDetailLabelPackageLanguage),
                            value: _str(i18n, pkg['resolvedLocale']),
                          ),
                      ],
                    ),
                  ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Quick-jump chip for long booking detail pages.
class _NavChip {
  final String label;
  final GlobalKey key;
  const _NavChip(this.label, this.key);
}

class _BookingQuickNavDelegate extends SliverPersistentHeaderDelegate {
  _BookingQuickNavDelegate({
    required this.height,
    required this.entries,
    required this.onSelect,
  });

  final double height;
  final List<_NavChip> entries;
  final Future<void> Function(GlobalKey key) onSelect;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(
      color: const Color(0xFFF4F6F9),
      elevation: overlapsContent ? 2 : 0,
      shadowColor: Colors.black26,
      child: SizedBox(
        height: height,
        child: Align(
          alignment: Alignment.centerLeft,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            itemCount: entries.length,
            separatorBuilder: (_, __) => const SizedBox(width: 6),
            itemBuilder: (context, i) {
              final e = entries[i];
              return ActionChip(
                label: Text(
                  e.label,
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                onPressed: () => onSelect(e.key),
                backgroundColor: Colors.white,
                side: BorderSide(color: AppColors.primary.withOpacity(0.35)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _BookingQuickNavDelegate oldDelegate) {
    if (oldDelegate.height != height) return true;
    if (oldDelegate.entries.length != entries.length) return true;
    for (var i = 0; i < entries.length; i++) {
      if (oldDelegate.entries[i].label != entries[i].label) return true;
    }
    return false;
  }
}

/// Long text: read more / less.
class _ExpandablePlainText extends StatefulWidget {
  const _ExpandablePlainText({
    required this.text,
    this.style,
    this.maxCollapsedLines = 4,
  });

  final String text;
  final TextStyle? style;
  final int maxCollapsedLines;

  @override
  State<_ExpandablePlainText> createState() => _ExpandablePlainTextState();
}

class _ExpandablePlainTextState extends State<_ExpandablePlainText> {
  bool _expanded = false;

  bool get _needsToggle {
    final t = widget.text;
    if (t.length > 220) return true;
    if (t.split('\n').length > widget.maxCollapsedLines) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final i18n = context.watch<UiI18n>();
    final style =
        widget.style ??
        Theme.of(context).textTheme.bodySmall?.copyWith(
          height: 1.45,
          color: const Color(0xFF5C6B7A),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.text,
          style: style,
          maxLines: _expanded ? null : widget.maxCollapsedLines,
          overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
        ),
        if (_needsToggle)
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.only(top: 2),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () => setState(() => _expanded = !_expanded),
            child: Text(
              _expanded
                  ? i18n.tr(I18nKey.bookingDetailReadLess)
                  : i18n.tr(I18nKey.bookingDetailReadMore),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
      ],
    );
  }
}

/// Many passengers: show a few rows, rest behind expansion.
class _PassengerCollapsibleList extends StatelessWidget {
  const _PassengerCollapsibleList({
    required this.passengers,
    required this.theme,
    required this.i18n,
  });

  final List<dynamic> passengers;
  final ThemeData theme;
  final UiI18n i18n;

  static const int _previewCount = 4;
  static const int _collapseWhenMoreThan = 6;

  @override
  Widget build(BuildContext context) {
    if (passengers.length <= _collapseWhenMoreThan) {
      return Column(
        children:
            passengers.asMap().entries.map((e) {
              final m = e.value as Map<String, dynamic>;
              return _PassengerTile(
                index: e.key + 1,
                m: m,
                theme: theme,
                i18n: i18n,
              );
            }).toList(),
      );
    }

    final head = passengers.take(_previewCount).toList();
    final tail = passengers.skip(_previewCount).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...head.asMap().entries.map((e) {
          final m = e.value as Map<String, dynamic>;
          return _PassengerTile(
            index: e.key + 1,
            m: m,
            theme: theme,
            i18n: i18n,
          );
        }),
        Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: const EdgeInsets.only(top: 4),
            initiallyExpanded: false,
            title: Text(
              i18n.tr(
                I18nKey.bookingDetailShowMorePassengers,
                params: {'count': '${tail.length}'},
              ),
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            subtitle: Text(
              i18n.tr(
                I18nKey.bookingDetailShowingFirstAbove,
                params: {'count': '$_previewCount'},
              ),
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.black45),
            ),
            children:
                tail.asMap().entries.map((e) {
                  final m = e.value as Map<String, dynamic>;
                  final idx = _previewCount + e.key + 1;
                  return _PassengerTile(
                    index: idx,
                    m: m,
                    theme: theme,
                    i18n: i18n,
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }
}

class _StatusHeader extends StatelessWidget {
  final UiI18n i18n;
  final String bookingId;
  final String statusLabel;
  final Color statusColor;
  final String? lifecycleHint;

  const _StatusHeader({
    required this.i18n,
    required this.bookingId,
    required this.statusLabel,
    required this.statusColor,
    this.lifecycleHint,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.88),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            i18n.tr(
              I18nKey.bookingDetailBookingNumber,
              params: {'id': bookingId},
            ),
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 4,
                height: 22,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (lifecycleHint != null &&
              lifecycleHint!.trim().isNotEmpty &&
              lifecycleHint != i18n.tr(I18nKey.commonEmDash)) ...[
            const SizedBox(height: 12),
            Text(
              lifecycleHint!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white.withOpacity(0.92),
                height: 1.45,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  final Color? accent;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = accent ?? AppColors.primary;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8ECF0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: c.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: c, size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A2332),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blueGrey.shade400),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueGrey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: valueColor ?? const Color(0xFF1A2332),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PassengerTile extends StatelessWidget {
  final int index;
  final Map<String, dynamic> m;
  final ThemeData theme;
  final UiI18n i18n;

  const _PassengerTile({
    required this.index,
    required this.m,
    required this.theme,
    required this.i18n,
  });

  String _empty(dynamic v) {
    if (v == null) return i18n.tr(I18nKey.commonEmDash);
    final s = v.toString().trim();
    return s.isEmpty ? i18n.tr(I18nKey.commonEmDash) : s;
  }

  @override
  Widget build(BuildContext context) {
    final dob = m['dateOfBirth'];
    final docType = m['documentType'];
    final docNo = m['documentNo'];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8ECF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$index. ${_empty(m['fullName'])}',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (dob != null && dob.toString().trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              i18n.tr(
                I18nKey.bookingDetailDateOfBirth,
                params: {'date': dob.toString()},
              ),
              style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF5C6B7A)),
            ),
          ],
          if (docType != null && docType.toString().trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              i18n.tr(
                I18nKey.bookingDetailDocument,
                params: {
                  'type': docType.toString(),
                  'doc': _empty(docNo),
                },
              ),
              style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF5C6B7A)),
            ),
          ],
        ],
      ),
    );
  }
}

class _PackageExtrasExpansion extends StatelessWidget {
  final Map<String, dynamic> pkg;
  final UiI18n i18n;

  const _PackageExtrasExpansion({required this.pkg, required this.i18n});

  List<String> _list(dynamic v) {
    if (v is! List) return [];
    return v.map((e) => e.toString().trim()).where((s) => s.isNotEmpty).toList();
  }

  @override
  Widget build(BuildContext context) {
    final activities = _list(pkg['activities']);
    final fees = _list(pkg['fees']);
    final facilities = _list(pkg['facilities']);
    final gettingThere = _list(pkg['gettingThere']);
    final opening = _list(pkg['openingHours']);
    final tips = _list(pkg['tipsForVisitors']);
    final must = _list(pkg['bringMustHave']);
    final optional = _list(pkg['bringOptional']);

    final hasExtra =
        activities.isNotEmpty ||
        fees.isNotEmpty ||
        facilities.isNotEmpty ||
        gettingThere.isNotEmpty ||
        opening.isNotEmpty ||
        tips.isNotEmpty ||
        must.isNotEmpty ||
        optional.isNotEmpty;

    if (!hasExtra) return const SizedBox.shrink();

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: false,
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 4),
        title: Text(
          i18n.tr(I18nKey.bookingDetailMoreFromPackage),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        children: [
          if (gettingThere.isNotEmpty)
            _BulletBlock(
              i18n: i18n,
              title: i18n.tr(I18nKey.bookingDetailBulletGettingThere),
              items: gettingThere,
            ),
          if (activities.isNotEmpty)
            _BulletBlock(
              i18n: i18n,
              title: i18n.tr(I18nKey.bookingDetailBulletActivities),
              items: activities,
            ),
          if (fees.isNotEmpty)
            _BulletBlock(
              i18n: i18n,
              title: i18n.tr(I18nKey.bookingDetailBulletFees),
              items: fees,
            ),
          if (facilities.isNotEmpty)
            _BulletBlock(
              i18n: i18n,
              title: i18n.tr(I18nKey.bookingDetailBulletFacilities),
              items: facilities,
            ),
          if (opening.isNotEmpty)
            _BulletBlock(
              i18n: i18n,
              title: i18n.tr(I18nKey.bookingDetailBulletOpening),
              items: opening,
            ),
          if (tips.isNotEmpty)
            _BulletBlock(
              i18n: i18n,
              title: i18n.tr(I18nKey.bookingDetailBulletTips),
              items: tips,
            ),
          if (must.isNotEmpty)
            _BulletBlock(
              i18n: i18n,
              title: i18n.tr(I18nKey.bookingDetailBulletMustBring),
              items: must,
            ),
          if (optional.isNotEmpty)
            _BulletBlock(
              i18n: i18n,
              title: i18n.tr(I18nKey.bookingDetailBulletOptionalBring),
              items: optional,
            ),
        ],
      ),
    );
  }
}

class _BulletBlock extends StatelessWidget {
  final UiI18n i18n;
  final String title;
  final List<String> items;

  const _BulletBlock({
    required this.i18n,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    const cap = 14;
    final extra = items.length > cap ? items.length - cap : 0;
    final display = extra > 0 ? items.sublist(0, cap) : items;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF5C6B7A),
            ),
          ),
          const SizedBox(height: 6),
          ...display.map(
            (t) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ',
                    style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w800),
                  ),
                  Expanded(
                    child: Text(
                      t,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        height: 1.4,
                        color: const Color(0xFF1A2332),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (extra > 0)
            Padding(
              padding: const EdgeInsets.only(top: 2, left: 4),
              child: Text(
                i18n.tr(
                  I18nKey.bookingDetailBulletTruncatedMore,
                  params: {'count': '$extra'},
                ),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: Colors.blueGrey.shade500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
