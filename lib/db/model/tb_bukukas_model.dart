class TbBukukasModel {
  int? id;
  String? name;

  TbBukukasModel({this.id, this.name});

  factory TbBukukasModel.fromJson(Map<String, dynamic> json) => TbBukukasModel(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}