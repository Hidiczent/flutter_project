class NotificationItem {
  final int orderId;
   String statusNotification;
  final String orderStatus;
  final String title;
  final String imageUrl;

  NotificationItem({
    required this.orderId,
    required this.statusNotification,
    required this.orderStatus,
    required this.title,
    required this.imageUrl,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      orderId: json['order_id'],
      statusNotification: json['status_notification'],
      orderStatus:
          json['order_status'], // เพิ่มข้อมูล order_status ที่ได้มาจาก API
      title: json['package_title'],
      imageUrl: json['main_image_url'] ?? '',
    );
  }
}
