class RestaurantNotification {
  String? notificationMessage;
  String? addedOn;
  String? orderId;
  String? userId;
  String? notificationType;

  RestaurantNotification(
      {this.notificationMessage,
      this.addedOn,
      this.orderId,
      this.userId,
      this.notificationType});

  RestaurantNotification.fromJson(Map<String, dynamic> json) {
    notificationMessage = json['notification_message'];
    addedOn = json['added_on'];
    orderId = json['order_id'];
    userId = json['user_id'];
    notificationType = json['notification_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['notification_message'] = this.notificationMessage;
    data['added_on'] = this.addedOn;
    data['order_id'] = this.orderId;
    data['user_id'] = this.userId;
    data['notification_type'] = this.notificationType;
    return data;
  }
}
