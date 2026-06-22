
/// Data model for notification item parsed from API JSON.
class NotificationItem {
  final String notificationId;
  final int orderId;
  String statusNotification;
  final String orderStatus;
  final String title;
  final String imageUrl;
  /// Lao Epic API `message` body (empty for legacy rows).
  final String message;

  NotificationItem({
    this.notificationId = '',
    required this.orderId,
    required this.statusNotification,
    required this.orderStatus,
    required this.title,
    required this.imageUrl,
    this.message = '',
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    final newApi =
        json.containsKey('notificationId') ||
        json.containsKey('notification_id');

    if (newApi) {
      final bookingId = json['bookingId'] ?? json['booking_id'];
      final isRead = json['isRead'] == true || json['is_read'] == true;
      final nid =
          json['notificationId']?.toString() ??
          json['notification_id']?.toString() ??
          '';
      return NotificationItem(
        notificationId: nid,
        orderId: int.tryParse(bookingId?.toString() ?? '') ?? 0,
        statusNotification: isRead ? 'read' : 'new',
        orderStatus: json['order_status']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        imageUrl: json['main_image_url']?.toString() ?? '',
        message: json['message']?.toString() ?? '',
      );
    }

    return NotificationItem(
      orderId: int.tryParse(json['order_id']?.toString() ?? '') ?? 0,
      statusNotification: json['status_notification']?.toString() ?? 'new',
      orderStatus: json['order_status']?.toString() ?? '',
      title: json['package_title']?.toString() ?? '',
      imageUrl: json['main_image_url']?.toString() ?? '',
      message: '',
    );
  }
}
