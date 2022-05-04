class LocationModel {
  String? city;
  String? state;
  String? address;
  String? lat;
  String? long;
  String? zipCode;

  LocationModel({
    this.city,
    this.state,
    this.address,
    this.lat,
    this.long,
    this.zipCode,
  });

  LocationModel.fromJson(Map<String, dynamic> json) {
    this.city = json['city'];
    this.state = json['state'];
    this.address = json['address'];
    this.lat = json['lat'];
    this.long = json['long'];
    this.zipCode = json['zipcode'];
  }
}
