
import 'package:flutter/material.dart';
import 'package:laoepic_thesis_app/data/models/invoice_pdf_data.dart';
import 'package:laoepic_thesis_app/theme/app_theme.dart';
import 'package:laoepic_thesis_app/features/booking/widgets/invoice_export_view.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Builds invoice PDF by rasterizing [InvoiceExportView] (correct Lao shaping, like web html2canvas).
class InvoicePdfBuilder {
  static const double _exportWidth = 520;
  static const double _maxExportHeight = 1600;
  static Future<pw.Document> build(
    InvoicePdfData data, {
    required BuildContext context,
    String localeCode = 'lo',
  }) async {
    final theme = AppTheme.light(localeCode);

    final exportWidget = Theme(
      data: theme,
      child: Material(
        color: Colors.white,
        child: SizedBox(
          width: _exportWidth,
          child: InvoiceExportView(data: data),
        ),
      ),
    );

    final image = await WidgetWrapper.fromWidget(
      context: context,
      widget: exportWidget,
      constraints: const BoxConstraints(
        maxWidth: _exportWidth,
        maxHeight: _maxExportHeight,
      ),
      pixelRatio: 3,
    );

    final doc = pw.Document();
    final format = PdfPageFormat.a4;
    const margin = 28.0;
    final contentWidth = format.width - margin * 2;
    final imgW = image.width!.toDouble();
    final imgH = image.height!.toDouble();
    final scaledHeight = imgH * contentWidth / imgW;
    final pageBodyHeight = format.height - margin * 2;

    var yOffset = 0.0;
    if (scaledHeight <= 0) {
      doc.addPage(
        pw.Page(
          pageFormat: format,
          margin: pw.EdgeInsets.all(margin),
          build: (_) => pw.Image(image, width: contentWidth),
        ),
      );
    } else {
      while (yOffset < scaledHeight - 0.5) {
        final sliceOffset = yOffset;
        doc.addPage(
          pw.Page(
            pageFormat: format,
            margin: pw.EdgeInsets.all(margin),
            build: (pwContext) {
              return pw.ClipRect(
                child: pw.Transform.translate(
                  offset: PdfPoint(0, -sliceOffset),
                  child: pw.Image(image, width: contentWidth),
                ),
              );
            },
          ),
        );
        yOffset += pageBodyHeight;
      }
    }

    return doc;
  }
}
