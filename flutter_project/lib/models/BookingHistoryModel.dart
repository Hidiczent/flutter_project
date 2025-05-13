class BookingHistoryModel {
  final int orderId;
  final String packageTitle;
  final String location;
  final double price;
  final String dateRange;
  final String status;
  final int points;
  final String imageUrl;

  BookingHistoryModel({
    required this.orderId,
    required this.packageTitle,
    required this.location,
    required this.price,
    required this.dateRange,
    required this.status,
    required this.points,
    required this.imageUrl,
  });

  factory BookingHistoryModel.fromJson(Map<String, dynamic> json) {
    return BookingHistoryModel(
      orderId: json['order_id'],
      packageTitle:
          json['package_title'] ?? 'No Title',
      location: json['location'] ?? 'Unknown',
      price: double.tryParse(json['price_in_usd'].toString()) ?? 0.0,
      dateRange: json['order_date'] ?? '',
      status: json['order_status'] ?? 'Pending',
      points: 100,
      imageUrl: json['main_image_url'] ?? '',
    );
  }
}
