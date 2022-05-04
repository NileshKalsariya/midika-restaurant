class ModifierModel {
  bool? is_enable;
  String? group_name;
  String? modifier_selection;
  List<Map<String, dynamic>>? modiferList;
  String? item_id;

  ModifierModel({
    this.is_enable,
    this.group_name,
    this.modiferList,
    this.modifier_selection,
    this.item_id,
  });

  ModifierModel.fromJson(Map<String, dynamic> data) {
    is_enable = data['is_enable'];
    group_name = data['group_name'];
    modifier_selection = data['modifier_selection'];
    modiferList = data['modifer_list'];
    item_id = data['item_id'];
  }
}
