class OperationalHours {
  int? number;
  String? day;
  bool isOpen24 = true;
  bool isClose = false;
  String? addedOn;
  String? openingTime;
  String? closingTime;

  OperationalHours(
      {required this.day,
      this.number,
      this.isOpen24 = true,
      this.isClose = false,
      this.addedOn,
      this.openingTime,
      this.closingTime});

  OperationalHours.fromJson(Map<String, dynamic> json) {
    this.number = json['number'];
    this.day = json['day'];
    this.isOpen24 = json['is_open24'];
    this.isClose = json['is_close'];
    this.openingTime = json['opening_time'];
    this.closingTime = json['closing_time'];
    this.addedOn = json['added_on'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['number'] = this.number;
    data['day'] = this.day;
    data['is_open24'] = this.isOpen24;
    data['is_close'] = this.isClose;
    data['opening_time'] = this.openingTime;
    data['closing_time'] = this.closingTime;
    data['added_on'] = this.addedOn;
    return data;
  }
}
