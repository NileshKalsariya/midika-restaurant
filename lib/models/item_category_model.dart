class ItemCategory {
  String? categoryName;
  // String? categoryImage;
  String? categoryId;
  // String? addedOn;

  ItemCategory({this.categoryName});

  ItemCategory.fromJson(Map<String, dynamic> json()) {
    this.categoryId = json()['category_id'];
    this.categoryName = json()['category_name'];
    // this.categoryImage = json()['category_image'];
    // this.addedOn = json()['added_on'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['category_id'] = this.categoryId;
    data['category_name'] = this.categoryName;
    // data['category_image'] = this.categoryImage;
    // data['added_on'] = this.addedOn;
    return data;
  }
}
