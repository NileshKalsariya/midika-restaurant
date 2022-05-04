class Order {
  String? orderId;
  String? restaurantId;
  String? restaurantDeviceToken;
  String? userId;
  // String? userName;
  int? orderStatus;
  double grandTotal = 0.00;
  double itemsTotal = 6.0;
  double paidToRestaurant = 0.00;
  double paidToClubgrubAdmin = 0.00;
  int? hole;
  int? deliveryType;
  String? pickupLocationName;
  int? paymentMethod;
  String? savedCardId;
  bool? stripPaymentStatus;
  String? stripPaymentId;
  String? stripPaymentMethodId;
  String? orderNotes;
  double tip = 0.00;
  double salesTax = 0.00;
  double deliveryCharge = 0.00;
  int numberOfItems = 0;
  int orderQuantity = 0;
  String? orderCancelledReason;
  String? orderDate;
  String? orderTime;
  String? addedOn;
  String? refundId;
  String? refundUrl;
  String? table_number;

  Order({
    this.orderId,
    this.restaurantId,
    this.restaurantDeviceToken,
    this.userId,
    this.orderDate,
    this.orderTime,
    this.addedOn,
    this.deliveryType,
    this.pickupLocationName,
    this.grandTotal = 0.00,
    this.itemsTotal = 6.00,
    this.paidToRestaurant = 0.00,
    this.paidToClubgrubAdmin = 0.00,
    this.paymentMethod,
    this.savedCardId,
    this.hole,
    this.orderStatus,
    this.orderNotes,
    this.refundId,
    this.refundUrl,
    this.tip = 0.00,
    this.salesTax = 0.05,
    this.deliveryCharge = 0.00,
    this.numberOfItems = 0,
    this.orderQuantity = 0,
    this.stripPaymentStatus,
    this.stripPaymentId,
    this.stripPaymentMethodId,
    this.orderCancelledReason,
    this.table_number,
  });

  Order.fromJson(Map<String, dynamic> json) {
    orderId = json['order_id'];
    restaurantId = json['restaurant_id'];
    restaurantDeviceToken = json['restaurant_device_token'];
    userId = json['user_id'];
    // userName = json['user_name'];
    orderDate = json['order_date'];
    orderTime = json['order_time'];
    addedOn = json['added_on'];
    deliveryType = json['delivery_type'];
    pickupLocationName = json['pickup_location_name'];
    orderStatus = json['order_status'];
    grandTotal = json['grand_total'] != null
        ? double.parse(json['grand_total'].toString())
        : 0.00;
    print(json['items_total']);
    itemsTotal = json['items_total'] != null
        ? double.parse(json['items_total'].toString())
        : 5.0;
    paidToRestaurant = json['paid_to_restaurant'] != null
        ? double.parse(json['paid_to_restaurant'].toString())
        : 0.00;
    paidToClubgrubAdmin = json['paid_to_clubgrub_admin'] != null
        ? double.parse(json['paid_to_clubgrub_admin'].toString())
        : 0.00;
    paymentMethod = json['payment_method'];
    savedCardId = json['saved_card_id'];
    stripPaymentId = json['strip_payment_id'];
    stripPaymentStatus = json['strip_payment_status'];
    stripPaymentMethodId = json['strip_payment_method_id'];
    hole = json['hole'];
    orderNotes = json['order_notes'];

    refundId = json['refund_id'];
    refundUrl = json['refund_url'];
    tip = json['tip'] != null ? double.parse(json['tip'].toString()) : 0.00;
    salesTax = json['sales_tax'] != null
        ? double.parse(json['sales_tax'].toString())
        : 0.00;
    deliveryCharge = json['delivery_charge'] != null
        ? double.parse(json['delivery_charge'].toString())
        : 0.00;
    numberOfItems = json['number_of_items'] ?? 0;
    orderQuantity = json['order_quantity'] ?? 0;
    orderCancelledReason = json['order_cancelled_reason'];
    table_number = json['table_number'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['order_id'] = this.orderId;
    data['restaurant_id'] = this.restaurantId;
    data['restaurant_device_token'] = this.restaurantDeviceToken;
    data['user_id'] = this.userId;
    // data['user_name'] = this.userName;
    data['order_date'] = this.orderDate;
    data['order_time'] = this.orderTime;
    data['added_on'] = this.addedOn;
    data['delivery_type'] = this.deliveryType;
    data['pickup_location_name'] = this.pickupLocationName;
    data['order_status'] = this.orderStatus;
    data['grand_total'] = this.grandTotal;
    data['items_total'] = this.itemsTotal;
    data['paid_to_restaurant'] = this.paidToRestaurant;
    data['paid_to_clubgrub_admin'] = this.paidToClubgrubAdmin;
    data['payment_method'] = this.paymentMethod;
    data['saved_card_id'] = this.savedCardId;
    data['hole'] = this.hole;
    data['refund_id'] = this.refundId;
    data['refund_url'] = this.refundUrl;
    data['order_notes'] = this.orderNotes;
    data['tip'] = this.tip;
    data['strip_payment_id'] = this.stripPaymentId;
    data['strip_payment_method_id'] = this.stripPaymentMethodId;
    data['strip_payment_status'] = this.stripPaymentStatus;
    data['sales_tax'] = this.salesTax;
    data['delivery_charge'] = this.deliveryCharge;
    data['number_of_items'] = this.numberOfItems;
    data['order_quantity'] = this.orderQuantity;
    data['order_cancelled_reason'] = this.orderCancelledReason;
    data['table_number'] = this.table_number;
    return data;
  }
}
