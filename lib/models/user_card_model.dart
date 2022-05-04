class UserCard {
  String? cardId;
  String? userId;
  String? cardNumber;
  String? expiryDate;
  String? cardHolderName;
  String? cvvCode;
  String? addedOn;


  UserCard({
    this.cardNumber,
    this.cardId,
    this.userId,
    this.expiryDate,
    this.cardHolderName,
    this.cvvCode,
    this.addedOn,

  });

  UserCard.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    cardId = json['card_id'];
    cardNumber = json['card_number'];
    expiryDate = json['expiry_date'];
    cardHolderName = json['card_holder_name'];
    cvvCode = json['cvv_code'];
    addedOn = json['added_on'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['card_number'] = this.cardNumber;
    data['card_id'] = this.cardId;
    data['user_id'] = this.userId;
    data['expiry_date'] = this.expiryDate;
    data['card_holder_name'] = this.cardHolderName;
    data['cvv_code'] = this.cvvCode;
    data['added_on'] = this.addedOn;

    return data;
  }
}
