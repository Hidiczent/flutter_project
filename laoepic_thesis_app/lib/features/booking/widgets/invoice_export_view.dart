
import 'package:flutter/material.dart';
import 'package:laoepic_thesis_app/data/models/invoice_pdf_data.dart';
import 'package:laoepic_thesis_app/theme/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Invoice layout rasterized for PDF — uses Flutter text shaping (correct Lao marks).
class InvoiceExportView extends StatelessWidget {
  final InvoicePdfData data;

  const InvoiceExportView({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ColoredBox(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SvgPicture.asset(
                      'assets/Logo/LaoEpic Logo 3.svg',
                      width: 96,
                      height: 40,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      data.activityLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: const Color(0xFF004C8C).withValues(alpha: 0.75),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      data.invoiceHeading,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF003366),
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F0FA),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        data.statusLabel,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    if (data.invoiceNo.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        data.invoiceNo,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            if (data.paidNote.isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  border: Border.all(color: Colors.green.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  data.paidNote,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 18),
            Text(
              data.packageTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: const Color(0xFF004C8C),
              ),
            ),
            if (data.location.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.place, size: 18, color: Colors.orange.shade700),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      data.location,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFF27C22),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 14),
            Text(
              '${data.customerLabel}: ${data.customerName}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF003366),
              ),
            ),
            const Divider(height: 28),
            _metaRow(theme, data.bookingIdLabel, data.bookingId),
            _metaRow(theme, data.bookingStatusLabel, data.bookingStatus),
            _metaRow(theme, data.travelersLabel, data.travelersSummary),
            if (data.departure.isNotEmpty)
              _metaRow(theme, data.departureLabel, data.departure),
            if (data.issueDate.isNotEmpty)
              _metaRow(theme, data.dateLabel, data.issueDate),
            const SizedBox(height: 16),
            Text(
              data.travelersSection,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(4),
                1: FlexColumnWidth(0.4),
              },
              border: TableBorder(
                bottom: BorderSide(color: AppColors.primary, width: 2),
              ),
              children: [
                TableRow(
                  children: [
                    _tableHead(theme, data.nameColumn),
                    _tableHead(theme, '#', align: TextAlign.right),
                  ],
                ),
                ...data.travelerNames.asMap().entries.map(
                  (e) => TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text(
                          e.value,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text(
                          '${e.key + 1}',
                          textAlign: TextAlign.right,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _totalRow(theme, data.subtotalLabel, data.subtotal),
            _totalRow(theme, data.taxLabel, data.tax),
            const Divider(height: 20),
            _totalRow(
              theme,
              data.grandTotalLabel,
              data.grandTotal,
              bold: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _metaRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableHead(
    ThemeData theme,
    String text, {
    TextAlign align = TextAlign.left,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        textAlign: align,
        style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _totalRow(
    ThemeData theme,
    String label,
    String value, {
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: bold ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: bold ? FontWeight.bold : FontWeight.w600,
              color: bold ? AppColors.primary : null,
            ),
          ),
        ],
      ),
    );
  }
}
