class QrCodeModel {
  String? addedOn;
  String? qrCodeUrl;
  String? qrCodeId;
  String? restaurantId;
  int? tableNo;

  QrCodeModel({
    this.addedOn,
    this.qrCodeUrl,
    this.qrCodeId,
    this.restaurantId,
    this.tableNo,
  });

  QrCodeModel.fromJson(Map<String, dynamic> json) {
    addedOn = json['added_on'];
    qrCodeUrl = json['qr_code_url'];
    qrCodeId = json['qr_code_id'];
    restaurantId = json['restaurant_id'];
    tableNo = json['table_no'];
  }

  Map<String, dynamic> toJson(QrCodeModel qrCodeModel) {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['added_on'] = qrCodeModel.addedOn;
    data['qr_code_url'] = qrCodeModel.qrCodeUrl;
    data['qr_code_id'] = qrCodeModel.qrCodeId;
    data['restaurant_id'] = qrCodeModel.restaurantId;
    data['table_no'] = qrCodeModel.tableNo;
    return data;
  }
}
