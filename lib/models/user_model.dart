class UserModel {
  String? uid;
  String? userName;
  String? email;
  String? mobileNumber;
  String? profileImageUrl;
  String? instaAccount;
  String? twitterAccount;
  String? fbAccount;
  double? latitude;
  double? longitude;
  String? address;
  String? device_token;

  UserModel({
    this.uid,
    this.userName,
    this.email,
    this.mobileNumber,
    this.profileImageUrl,
    this.instaAccount,
    this.twitterAccount,
    this.fbAccount,
    this.latitude,
    this.longitude,
    this.address,
    this.device_token,
  });

  ///from json
  UserModel.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    userName = json['user_name'];
    email = json['email_id'];
    mobileNumber = json['mobile_Number'];
    profileImageUrl = json['profile_image_url'];
    instaAccount = json['insta_Account'];
    twitterAccount = json['twitter_Account'];
    fbAccount = json['fb_Account'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    address = json['address'];
    device_token = json['device_token'];
  }

  ///to json
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = new Map<String, dynamic>();
    _data["uid"] = uid;
    _data["user_name"] = userName;
    _data["email_id"] = email;
    _data["mobile_Number"] = mobileNumber;
    _data["profile_image_url"] = profileImageUrl;
    _data["insta_Account"] = instaAccount;
    _data["twitter_Account"] = twitterAccount;
    _data["fb_Account"] = fbAccount;
    _data["latitude"] = latitude;
    _data["longitude"] = longitude;
    _data["address"] = address;
    _data["device_token"] = device_token;
    return _data;
  }
}
