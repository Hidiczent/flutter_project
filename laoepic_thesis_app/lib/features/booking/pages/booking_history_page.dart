
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:laoepic_thesis_app/features/booking/pages/booking_detail_page.dart';
import 'package:laoepic_thesis_app/core/api/api_locale_prefs.dart';
import 'package:laoepic_thesis_app/config/app_config.dart';
import 'package:laoepic_thesis_app/i18n/i18n_keys.dart';
import 'package:laoepic_thesis_app/i18n/ui_i18n.dart';
import 'package:laoepic_thesis_app/data/models/booking_history_model.dart';
import 'package:laoepic_thesis_app/theme/app_colors.dart';
import 'package:laoepic_thesis_app/shared/widgets/app_feedback.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:laoepic_thesis_app/shared/utils/money_format.dart';
import 'package:laoepic_thesis_app/features/booking/widgets/booking_review_section.dart';

const Color _pageBg = Color(0xFFF4F6F9);

/// Lists the traveler's past and upcoming tour bookings with filters and quick navigation.
class BookingHistoryPage extends StatefulWidget {
  const BookingHistoryPage({super.key});

  @override
  State<BookingHistoryPage> createState() => _BookingHistoryPageState();
}

class _BookingHistoryPageState extends State<BookingHistoryPage> {
  late Future<List<BookingHistoryModel>> _historyFuture;
  String? _statusFilter;

  @override
  void initState() {
    super.initState();
    _historyFuture = _fetchBookingHistory();
  }

  Future<void> _reload() async {
    setState(() {
      _historyFuture = _fetchBookingHistory();
    });
    await _historyFuture;
  }

  Future<List<BookingHistoryModel>> _fetchBookingHistory() async {
    final i18n = context.read<UiI18n>();
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null) {
      throw Exception(i18n.tr(I18nKey.historyNotLoggedIn));
    }

    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/bookings/me'),
      headers: await buildAuthApiHeaders(token),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final raw = body['data'];
      if (body['success'] == true && raw is List) {
        return raw
            .map((e) => BookingHistoryModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    }
    throw Exception(i18n.tr(I18nKey.historyLoadFail));
  }

  List<BookingHistoryModel> _applyFilter(List<BookingHistoryModel> list) {
    if (_statusFilter == null) return list;
    return list.where((b) => b.status.toLowerCase() == _statusFilter).toList();
  }

  String _humanizeCancelError(UiI18n i18n, String msg) {
    final lower = msg.toLowerCase();
    if (lower.contains('calendar day') ||
        lower.contains('before departure') ||
        lower.contains('cancellation is only allowed')) {
      return i18n.tr(I18nKey.historyCancelTooLate, params: {'days': '7'});
    }
    if (msg.trim().isEmpty) {
      return i18n.tr(I18nKey.historyCancelFailGeneric);
    }
    return msg;
  }

  Future<void> _cancelOrder(int orderId, String reason) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    final i18n = context.read<UiI18n>();

    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/bookings/$orderId/cancel'),
      headers: {
        ...await buildAuthApiHeaders(token),
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'reason': reason.isEmpty ? 'Cancelled by user' : reason,
      }),
    );

    if (!mounted) return;

    if (response.statusCode == 200) {
      var message = i18n.tr(I18nKey.historyCancelSuccess);
      try {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final mode = body['mode']?.toString();
        if (mode == 'request') {
          message = i18n.tr(I18nKey.historyCancelRequestSubmitted);
        } else if (body['message'] is String &&
            body['message'].toString().isNotEmpty) {
          message = body['message'].toString();
        }
      } catch (_) {}

      await context.showSuccessMessage(message);
      await _reload();
    } else {
      final raw = response.body;
      final parsed = _humanizeCancelError(
        i18n,
        parseApiFeedbackMessage(raw),
      );
                      await context.showBusinessNoticeMessage(parsed);
    }
  }

  Future<Map<String, dynamic>?> _fetchCancellationPolicy() async {
    try {
      final res = await http.get(
        Uri.parse('${AppConfig.baseUrl}/bookings/cancellation-policy'),
        headers: await buildPublicApiHeaders(),
      );
      if (res.statusCode != 200) return null;
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (body['success'] == true && body['data'] is Map) {
        return Map<String, dynamic>.from(body['data'] as Map);
      }
    } catch (_) {}
    return null;
  }

  void _showCancelDialog(BookingHistoryModel item) async {
    final i18n = context.read<UiI18n>();
    final reasonController = TextEditingController();
    final policy = await _fetchCancellationPolicy();
    if (!mounted) return;

    final policyTitle =
        policy?['title']?.toString() ??
        i18n.tr(I18nKey.historyCancelPolicyTitle);
    final rules =
        (policy?['rules'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .where((s) => s.isNotEmpty)
            .toList() ??
        <String>[];

    var policyAccepted = false;

    showDialog<void>(
      context: context,
      builder:
          (ctx) => StatefulBuilder(
            builder: (ctx, setDialogState) {
              final confirmText =
                  item.isRequestCancel
                      ? i18n.tr(I18nKey.historyCancelConfirmRequest)
                      : i18n.tr(I18nKey.historyCancelConfirm);
              final canSubmit = rules.isEmpty || policyAccepted;

              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.red.shade400,
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(i18n.tr(I18nKey.historyCancelTitle))),
                  ],
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        confirmText,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.45,
                          color: Colors.blueGrey.shade700,
                        ),
                      ),
                      if (rules.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF8E1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFFE082)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.policy_outlined,
                                    size: 18,
                                    color: Colors.amber.shade900,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      policyTitle,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                        color: Colors.amber.shade900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ...rules.map(
                                (rule) => Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '• ',
                                        style: TextStyle(
                                          color: Colors.amber.shade900,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          rule,
                                          style: TextStyle(
                                            fontSize: 12,
                                            height: 1.4,
                                            color: Colors.brown.shade800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        CheckboxListTile(
                          value: policyAccepted,
                          onChanged: (v) {
                            setDialogState(() => policyAccepted = v ?? false);
                          },
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          title: Text(
                            i18n.tr(I18nKey.historyCancelPolicyAgree),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.blueGrey.shade800,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      TextField(
                        controller: reasonController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: i18n.tr(I18nKey.historyReasonLabel),
                          hintText: i18n.tr(I18nKey.historyReasonHint),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(i18n.tr(I18nKey.commonClose)),
                  ),
                  FilledButton.icon(
                    onPressed:
                        canSubmit
                            ? () {
                              Navigator.pop(ctx);
                              _cancelOrder(item.orderId, reasonController.text);
                            }
                            : null,
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: Text(i18n.tr(I18nKey.commonConfirm)),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFC62828),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
    );
  }

  void _openDetail(int orderId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BookingDetailPage(orderId: orderId)),
    ).then((_) {
      if (mounted) _reload();
    });
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

  @override
  Widget build(BuildContext context) {
    final i18n = context.watch<UiI18n>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: _pageBg,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        foregroundColor: Colors.white,
        title: Text(
          i18n.tr(I18nKey.historyTitle),
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        actions: [
          IconButton(
            tooltip: i18n.tr(I18nKey.commonRefresh),
            onPressed: _reload,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: Colors.white,
            elevation: 0,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  _FilterChip(
                    label: i18n.tr(I18nKey.historyFilterAll),
                    selected: _statusFilter == null,
                    onTap: () => setState(() => _statusFilter = null),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: i18n.tr(I18nKey.historyFilterPending),
                    selected: _statusFilter == 'pending',
                    onTap: () => setState(() => _statusFilter = 'pending'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: i18n.tr(I18nKey.historyFilterConfirmed),
                    selected: _statusFilter == 'confirmed',
                    onTap: () => setState(() => _statusFilter = 'confirmed'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: i18n.tr(I18nKey.historyFilterCancelled),
                    selected: _statusFilter == 'cancelled',
                    onTap: () => setState(() => _statusFilter = 'cancelled'),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: FutureBuilder<List<BookingHistoryModel>>(
              future: _historyFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 36,
                          height: 36,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          i18n.tr(I18nKey.commonLoading),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: _reload,
                    child: _EmptyState(
                      icon: Icons.cloud_off_outlined,
                      title: i18n.tr(I18nKey.historyErrorTitle),
                      message: i18n.tr(
                        I18nKey.historyError,
                        params: {'error': '${snapshot.error}'},
                      ),
                      actionLabel: i18n.tr(I18nKey.commonTryAgain),
                      onAction: _reload,
                      accent: AppColors.primary,
                    ),
                  );
                }

                final all = snapshot.data ?? [];
                final filtered = _applyFilter(all);

                if (all.isEmpty) {
                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: _reload,
                    child: _EmptyState(
                      icon: Icons.card_travel_outlined,
                      title: i18n.tr(I18nKey.historyEmptyTitle),
                      message: i18n.tr(I18nKey.historyEmptyMessage),
                      actionLabel: i18n.tr(I18nKey.commonRefresh),
                      onAction: _reload,
                      accent: AppColors.accent,
                    ),
                  );
                }

                if (filtered.isEmpty) {
                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: _reload,
                    child: _EmptyState(
                      icon: Icons.filter_list_off_rounded,
                      title: i18n.tr(I18nKey.historyEmpty),
                      message: i18n.tr(I18nKey.historyEmptyMessage),
                      actionLabel: i18n.tr(I18nKey.historyFilterAll),
                      onAction: () => setState(() => _statusFilter = null),
                      accent: AppColors.primary,
                    ),
                  );
                }

                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: _reload,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return _BookingHistoryCard(
                        item: item,
                        i18n: i18n,
                        statusLabel: _statusLabel(i18n, item.status),
                        statusColor: _statusColor(item.status),
                        onTap: () => _openDetail(item.orderId),
                        onCancel:
                            item.canCancel
                                ? () => _showCancelDialog(item)
                                : null,
                        onPay:
                            item.needsPayment
                                ? () => _openDetail(item.orderId)
                                : null,
                        onReviewSubmitted: _reload,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      labelStyle: TextStyle(
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        fontSize: 13,
        color: selected ? Colors.white : AppColors.primary,
      ),
      backgroundColor: Colors.white,
      selectedColor: AppColors.primary,
      side: BorderSide(
        color:
            selected ? AppColors.primary : AppColors.primary.withOpacity(0.35),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
    );
  }
}

class _BookingHistoryCard extends StatelessWidget {
  final BookingHistoryModel item;
  final UiI18n i18n;
  final String statusLabel;
  final Color statusColor;
  final VoidCallback onTap;
  final VoidCallback? onCancel;
  final VoidCallback? onPay;
  final VoidCallback? onReviewSubmitted;

  const _BookingHistoryCard({
    required this.item,
    required this.i18n,
    required this.statusLabel,
    required this.statusColor,
    required this.onTap,
    this.onCancel,
    this.onPay,
    this.onReviewSubmitted,
  });

  String _formatDeparture(String iso) {
    if (iso.isEmpty) return i18n.tr(I18nKey.commonEmDash);
    try {
      return DateFormat(
        'dd MMM yyyy · HH:mm',
      ).format(DateTime.parse(iso).toLocal());
    } catch (_) {
      return iso;
    }
  }

  String _formatMoney() {
    return i18n.tr(
      I18nKey.historyTotal,
      params: {
        'amount': MoneyFormat.formatAmount(item.price),
        'currency': MoneyFormat.normalizeCurrency(item.currencyCode),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color:
                  item.needsPayment
                      ? AppColors.accent.withOpacity(0.45)
                      : const Color(0xFFE8ECF0),
              width: item.needsPayment ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(17),
                ),
                child: Stack(
                  children: [
                    SizedBox(
                      height: 108,
                      width: double.infinity,
                      child: Image.asset(
                        'assets/images/Act3.jpg',
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) => Container(
                              color: AppColors.primary.withOpacity(0.12),
                              child: Icon(
                                Icons.landscape_rounded,
                                size: 48,
                                color: AppColors.primary.withOpacity(0.35),
                              ),
                            ),
                      ),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.55),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 14,
                      right: 14,
                      bottom: 12,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Text(
                              item.packageTitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                                shadows: const [
                                  Shadow(color: Colors.black38, blurRadius: 6),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.92),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              statusLabel,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      i18n.tr(
                        I18nKey.historyBookingRef,
                        params: {'id': '${item.orderId}'},
                      ),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: Colors.blueGrey.shade500,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                    if (item.location.trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.place_outlined,
                            size: 18,
                            color: AppColors.primary.withOpacity(0.85),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              item.location,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF5C6B7A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_month_outlined,
                          size: 18,
                          color: Colors.blueGrey.shade400,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _formatDeparture(item.departureIso),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF5C6B7A),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.groups_2_outlined,
                          size: 18,
                          color: Colors.blueGrey.shade400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          i18n.tr(
                            I18nKey.historyTravelersCount,
                            params: {'count': '${item.peopleCount}'},
                          ),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF5C6B7A),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    if (item.cancellationPending) ...[
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFFCC80)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.hourglass_top_rounded,
                              size: 18,
                              color: Colors.orange.shade800,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.cancelHint.trim().isNotEmpty
                                    ? item.cancelHint
                                    : i18n.tr(I18nKey.historyCancelPending),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.orange.shade900,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (item.lifecycleHint.trim().isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accentSurface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.accent.withOpacity(0.25),
                          ),
                        ),
                        child: Text(
                          item.lifecycleHint,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF6D4C1A),
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Text(
                      _formatMoney(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    if (item.points > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        i18n.tr(
                          I18nKey.historyCollectionPoints,
                          params: {'points': '${item.points}'},
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    BookingReviewSection(
                      booking: item.sourceJson,
                      onReviewSubmitted: onReviewSubmitted,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: onTap,
                            icon: const Icon(
                              Icons.visibility_outlined,
                              size: 18,
                            ),
                            label: Text(i18n.tr(I18nKey.historyViewDetails)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: BorderSide(
                                color: AppColors.primary.withOpacity(0.4),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                        if (onPay != null) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: onPay,
                              icon: const Icon(Icons.payment_rounded, size: 18),
                              label: Text(
                                i18n.tr(I18nKey.historyCompletePayment),
                              ),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.accent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ),
                        ] else if (onCancel != null) ...[
                          const SizedBox(width: 8),
                          TextButton.icon(
                            onPressed: onCancel,
                            icon: Icon(
                              Icons.cancel_outlined,
                              size: 18,
                              color: Colors.red.shade400,
                            ),
                            label: Text(
                              i18n.tr(I18nKey.historyCancel),
                              style: TextStyle(color: Colors.red.shade400),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;
  final Color accent;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, size: 52, color: accent),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A2332),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.45,
                        color: Colors.blueGrey.shade600,
                      ),
                    ),
                    const SizedBox(height: 28),
                    FilledButton.icon(
                      onPressed: onAction,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.refresh_rounded, size: 20),
                      label: Text(actionLabel),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
