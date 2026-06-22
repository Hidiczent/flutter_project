
/// Data model for invoice pdf data parsed from API JSON.
class InvoicePdfData {
  final String activityLabel;
  final String invoiceHeading;
  final String invoiceNo;
  final String statusLabel;
  final String paidNote;
  final String packageTitle;
  final String location;
  final String customerLabel;
  final String customerName;
  final String bookingIdLabel;
  final String bookingId;
  final String bookingStatusLabel;
  final String bookingStatus;
  final String travelersLabel;
  final String travelersSummary;
  final String departureLabel;
  final String departure;
  final String dateLabel;
  final String issueDate;
  final String travelersSection;
  final String nameColumn;
  final List<String> travelerNames;
  final String subtotalLabel;
  final String subtotal;
  final String taxLabel;
  final String tax;
  final String grandTotalLabel;
  final String grandTotal;

  const InvoicePdfData({
    required this.activityLabel,
    required this.invoiceHeading,
    required this.invoiceNo,
    required this.statusLabel,
    required this.paidNote,
    required this.packageTitle,
    required this.location,
    required this.customerLabel,
    required this.customerName,
    required this.bookingIdLabel,
    required this.bookingId,
    required this.bookingStatusLabel,
    required this.bookingStatus,
    required this.travelersLabel,
    required this.travelersSummary,
    required this.departureLabel,
    required this.departure,
    required this.dateLabel,
    required this.issueDate,
    required this.travelersSection,
    required this.nameColumn,
    required this.travelerNames,
    required this.subtotalLabel,
    required this.subtotal,
    required this.taxLabel,
    required this.tax,
    required this.grandTotalLabel,
    required this.grandTotal,
  });
}
