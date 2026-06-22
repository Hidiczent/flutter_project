import 'package:flutter/material.dart';
import 'package:laoepic_thesis_app/i18n/i18n_keys.dart';
import 'package:laoepic_thesis_app/i18n/ui_i18n.dart';
import 'package:laoepic_thesis_app/data/models/package_model.dart';
import 'package:laoepic_thesis_app/theme/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:laoepic_thesis_app/shared/utils/money_format.dart';
import 'package:provider/provider.dart';

const Color _surfaceCard = Color(0xFFFFFFFF);
const List<Color> _pageGradient = [
  Color(0xFFD8E8F5),
  Color(0xFFEEF4FB),
  Color(0xFFF7FAFD),
];

/// Departures, capacity, and schedule prices from API `schedules`.
class PackageActivityTab extends StatelessWidget {
  final PackageModel package;

  const PackageActivityTab({super.key, required this.package});

  String _fmt(String? iso) {
    if (iso == null || iso.isEmpty) return '—';
    try {
      return DateFormat(
        'dd/MM/yyyy HH:mm',
      ).format(DateTime.parse(iso).toLocal());
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    final schedules = package.schedules;

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _pageGradient,
          stops: [0.0, 0.45, 1.0],
        ),
      ),
      child:
          schedules.isEmpty
              ? _buildEmpty(context)
              : _buildList(context, schedules),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    final i18n = context.watch<UiI18n>();
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy_rounded,
              size: 56,
              color: AppColors.primary.withOpacity(0.45),
            ),
            const SizedBox(height: 16),
            Text(
              i18n.tr(I18nKey.departuresEmptyTitle),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              i18n.tr(I18nKey.departuresEmptyBody),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, List<PackageSchedule> schedules) {
    final i18n = context.watch<UiI18n>();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.75),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.9)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  color: AppColors.primary,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      i18n.tr(I18nKey.departuresHeaderTitle),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      package.durationDays != null
                          ? i18n.tr(
                            I18nKey.departuresSuggestedDays,
                            params: {'days': '${package.durationDays}'},
                          )
                          : i18n.tr(I18nKey.departuresPickBelow),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blueGrey.shade700,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        ...schedules.map((s) => _ScheduleCard(s: s, fmt: _fmt, i18n: i18n)),
      ],
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final PackageSchedule s;
  final String Function(String?) fmt;
  final UiI18n i18n;

  const _ScheduleCard({required this.s, required this.fmt, required this.i18n});

  @override
  Widget build(BuildContext context) {
    final open = s.status.toLowerCase() == 'open';
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: _surfaceCard,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.65),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 16, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _LabeledRow(
                                  icon: Icons.flight_takeoff_rounded,
                                  iconColor: const Color(0xFF1565C0),
                                  label: i18n.tr(
                                    I18nKey.departuresLabelDeparture,
                                  ),
                                  value: fmt(s.departureDatetime),
                                  emphasize: true,
                                ),
                                const SizedBox(height: 10),
                                _LabeledRow(
                                  icon: Icons.flight_land_rounded,
                                  iconColor: const Color(0xFF6A1B9A),
                                  label: i18n.tr(I18nKey.departuresLabelReturn),
                                  value: fmt(s.returnDatetime),
                                ),
                              ],
                            ),
                          ),
                          _StatusChip(open: open, status: s.status),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _LabeledRow(
                        icon: Icons.event_seat_rounded,
                        iconColor: const Color(0xFF2E7D32),
                        label: i18n.tr(I18nKey.departuresAvailability),
                        value: i18n.tr(
                          I18nKey.departuresSeatsLeft,
                          params: {
                            'left': '${s.seatsLeft}',
                            'total': '${s.capacity}',
                          },
                        ),
                      ),
                      if (s.note != null && s.note!.trim().isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF8E1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFFFE082).withOpacity(0.8),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                size: 18,
                                color: Colors.amber.shade900,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  s.note!.trim(),
                                  style: TextStyle(
                                    fontSize: 13,
                                    height: 1.35,
                                    color: Colors.brown.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (s.prices.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Text(
                          i18n.tr(I18nKey.departuresPrices),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: Colors.blueGrey.shade800,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              s.prices
                                  .map((p) => _PriceChip(price: p, i18n: i18n))
                                  .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool open;
  final String status;

  const _StatusChip({required this.open, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              open
                  ? [const Color(0xFFE8F5E9), const Color(0xFFC8E6C9)]
                  : [Colors.grey.shade200, Colors.grey.shade300],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: open ? const Color(0xFF81C784) : Colors.grey.shade400,
          width: 0.5,
        ),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: open ? const Color(0xFF1B5E20) : Colors.grey.shade800,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _LabeledRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final bool emphasize;

  const _LabeledRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey.shade500,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: emphasize ? 15 : 14,
                  fontWeight: emphasize ? FontWeight.w700 : FontWeight.w600,
                  color:
                      emphasize ? AppColors.primary : Colors.blueGrey.shade900,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PriceChip extends StatelessWidget {
  final SchedulePrice price;
  final UiI18n i18n;

  const _PriceChip({required this.price, required this.i18n});

  String _label(String type) {
    switch (type.toLowerCase()) {
      case 'adult':
        return i18n.tr(I18nKey.departuresPriceAdult);
      case 'child':
        return i18n.tr(I18nKey.departuresPriceChild);
      case 'vip':
        return i18n.tr(I18nKey.departuresPriceVip);
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        // color: AppColors.accent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.accent.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _label(price.priceType),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey.shade600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            MoneyFormat.format(price.amount, currency: price.currencyCode),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.accent,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}
